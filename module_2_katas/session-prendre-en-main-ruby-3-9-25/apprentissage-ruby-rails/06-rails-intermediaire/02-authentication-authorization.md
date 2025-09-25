# Authentication et Authorization avec Rails 7

## Introduction

L'**authentification** vérifie l'identité de l'utilisateur, tandis que l'**autorisation** détermine ce qu'il peut faire. Rails 7 offre plusieurs approches modernes.

## 1. Authentication avec Devise

### Installation et configuration
```ruby
# Gemfile
gem 'devise'

# Installation
rails generate devise:install
rails generate devise User
rails db:migrate

# Configuration personnalisée
rails generate devise:views
```

### Configuration Devise moderne
```ruby
# config/initializers/devise.rb
Devise.setup do |config|
  # Clé secrète
  config.secret_key = Rails.application.credentials.secret_key_base

  # Configuration email
  config.mailer_sender = 'noreply@monapp.com'

  # Stratégies d'authentification
  config.authentication_keys = [:email]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # Sécurité des sessions
  config.timeout_in = 30.minutes
  config.expire_auth_token_on_timeout = true

  # Confirmation par email
  config.confirm_within = 3.days
  config.reconfirmable = true

  # Verrouillage de compte
  config.lock_strategy = :failed_attempts
  config.maximum_attempts = 5
  config.unlock_in = 1.hour

  # Configuration des mots de passe
  config.password_length = 8..128
  config.reset_password_within = 6.hours
end
```

### Modèle User avec Devise
```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable

  # Associations
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one_attached :avatar

  # Validations personnalisées
  validates :first_name, :last_name, presence: true, length: { minimum: 2 }
  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_]+\z/ }

  # Énumérations pour les rôles
  enum role: { user: 0, admin: 1, moderator: 2 }

  # Méthodes utiles
  def full_name
    "#{first_name} #{last_name}"
  end

  def display_name
    username.presence || full_name
  end

  def avatar_url
    avatar.attached? ? Rails.application.routes.url_helpers.rails_blob_url(avatar) : nil
  end

  # Callbacks
  before_save :normalize_email
  after_create :send_welcome_email

  private

  def normalize_email
    self.email = email.downcase.strip
  end

  def send_welcome_email
    UserMailer.welcome(self).deliver_later
  end
end
```

### Contrôleurs Devise personnalisés
```ruby
# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def create
    super do |resource|
      if resource.persisted?
        UserMailer.welcome(resource).deliver_later
        flash[:success] = "Bienvenue ! Consultez votre email pour confirmer votre compte."
      end
    end
  end

  def update
    super do |resource|
      if resource.errors.empty?
        flash[:success] = "Profil mis à jour avec succès"
      end
    end
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :username])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :username, :avatar])
  end

  def update_resource(resource, params)
    if params[:password].blank? && params[:password_confirmation].blank?
      resource.update_without_password(params.except(:current_password))
    else
      resource.update_with_password(params)
    end
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end
end

# config/routes.rb
devise_for :users, controllers: {
  registrations: 'users/registrations',
  sessions: 'users/sessions',
  passwords: 'users/passwords'
}
```

## 2. Authorization avec Pundit

### Installation et configuration
```ruby
# Gemfile
gem 'pundit'

# Installation
rails generate pundit:install
```

### Application Policy de base
```ruby
# app/policies/application_policy.rb
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NotImplementedError
    end

    private

    attr_reader :user, :scope
  end
end
```

### Policy pour les articles
```ruby
# app/policies/article_policy.rb
class ArticlePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || owner? || admin?
  end

  def create?
    user.present?
  end

  def update?
    owner? || admin?
  end

  def destroy?
    owner? || admin?
  end

  def publish?
    owner? || admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user&.present?
        scope.where("status = 'published' OR user_id = ?", user.id)
      else
        scope.published
      end
    end
  end

  private

  def owner?
    user == record.user
  end

  def admin?
    user&.admin?
  end
end
```

### Contrôleur avec Pundit
```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  include Pundit::Authorization

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_article, only: [:show, :edit, :update, :destroy, :publish]

  def index
    @articles = policy_scope(Article).includes(:user).page(params[:page])
  end

  def show
    authorize @article
  end

  def new
    @article = Article.new
    authorize @article
  end

  def create
    @article = current_user.articles.build(article_params)
    authorize @article

    if @article.save
      redirect_to @article, notice: 'Article créé avec succès'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @article
  end

  def update
    authorize @article

    if @article.update(article_params)
      redirect_to @article, notice: 'Article mis à jour'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @article
    @article.destroy
    redirect_to articles_path, notice: 'Article supprimé'
  end

  def publish
    authorize @article, :publish?
    @article.update(status: 'published', published_at: Time.current)
    redirect_to @article, notice: 'Article publié'
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content, :status)
  end
end
```

## 3. Authorization basée sur les rôles

### Système de rôles avancé
```ruby
# app/models/role.rb
class Role < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  scope :active, -> { where(active: true) }
end

# app/models/permission.rb
class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :name, presence: true, uniqueness: true
  validates :resource, :action, presence: true

  def to_s
    "#{action}_#{resource}"
  end
end

# app/models/user.rb (extension)
class User < ApplicationRecord
  # ... code précédent ...

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  def has_role?(role_name)
    roles.exists?(name: role_name.to_s)
  end

  def add_role(role_name)
    role = Role.find_by(name: role_name.to_s)
    roles << role if role && !has_role?(role_name)
  end

  def remove_role(role_name)
    role = roles.find_by(name: role_name.to_s)
    roles.delete(role) if role
  end

  def has_permission?(permission_name)
    roles.joins(:permissions)
         .where(permissions: { name: permission_name })
         .exists?
  end

  def can?(action, resource)
    has_permission?("#{action}_#{resource}")
  end
end
```

### Concern pour l'autorisation
```ruby
# app/controllers/concerns/authorization.rb
module Authorization
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  def require_admin
    redirect_to root_path unless current_user&.admin?
  end

  def require_permission(permission)
    unless current_user&.has_permission?(permission)
      flash[:alert] = "Vous n'avez pas les permissions nécessaires"
      redirect_to root_path
    end
  end

  def require_role(role)
    unless current_user&.has_role?(role)
      flash[:alert] = "Accès restreint"
      redirect_to root_path
    end
  end

  private

  def user_not_authorized
    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action"
    redirect_back(fallback_location: root_path)
  end
end
```

## 4. API Authentication avec JWT

### Configuration JWT
```ruby
# Gemfile
gem 'jwt'

# app/services/jwt_service.rb
class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    raise JWT::DecodeError, e.message
  end
end
```

### API Authentication Controller
```ruby
# app/controllers/api/v1/authentication_controller.rb
class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [:login, :register]

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = JwtService.encode(user_id: user.id)

      render json: {
        user: user.slice(:id, :email, :first_name, :last_name),
        token: token,
        expires_at: 24.hours.from_now
      }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  def register
    user = User.new(user_params)

    if user.save
      token = JwtService.encode(user_id: user.id)

      render json: {
        user: user.slice(:id, :email, :first_name, :last_name),
        token: token
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def logout
    # Dans une vraie app, on maintiendrait une blacklist de tokens
    head :no_content
  end

  def me
    render json: {
      user: current_user.slice(:id, :email, :first_name, :last_name, :roles)
    }
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
  end
end
```

## 5. Middleware d'authentification

```ruby
# app/controllers/application_controller.rb (pour API)
class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header

    begin
      @decoded = JwtService.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: 'User not found' }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: 'Invalid token' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def admin_required
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end
end
```

## 6. Tests d'authentification et d'autorisation

```ruby
# spec/policies/article_policy_spec.rb
require 'rails_helper'

RSpec.describe ArticlePolicy, type: :policy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:article) { create(:article, user: user) }

  subject { described_class }

  permissions '.scope' do
    it 'shows published articles to guests' do
      published = create(:article, status: 'published')
      draft = create(:article, status: 'draft')

      expect(Pundit.policy_scope(nil, Article)).to include(published)
      expect(Pundit.policy_scope(nil, Article)).not_to include(draft)
    end

    it 'shows own drafts to users' do
      own_draft = create(:article, user: user, status: 'draft')
      other_draft = create(:article, status: 'draft')

      scope = Pundit.policy_scope(user, Article)
      expect(scope).to include(own_draft)
      expect(scope).not_to include(other_draft)
    end
  end

  permissions :show? do
    it 'grants access to published articles' do
      article.update(status: 'published')
      expect(subject).to permit(nil, article)
    end

    it 'denies access to drafts for non-owners' do
      other_user = create(:user)
      expect(subject).not_to permit(other_user, article)
    end

    it 'grants access to own drafts' do
      expect(subject).to permit(user, article)
    end
  end

  permissions :update? do
    it 'grants access to owner' do
      expect(subject).to permit(user, article)
    end

    it 'grants access to admin' do
      expect(subject).to permit(admin, article)
    end

    it 'denies access to other users' do
      other_user = create(:user)
      expect(subject).not_to permit(other_user, article)
    end
  end
end

# spec/requests/authentication_spec.rb
require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /api/v1/auth/login' do
    let(:user) { create(:user, password: 'password123') }

    it 'authenticates with valid credentials' do
      post '/api/v1/auth/login', params: {
        email: user.email,
        password: 'password123'
      }

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to include('token', 'user')
    end

    it 'rejects invalid credentials' do
      post '/api/v1/auth/login', params: {
        email: user.email,
        password: 'wrongpassword'
      }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
```

Cette approche moderne de l'authentification et de l'autorisation vous donne un système sécurisé et flexible ! 🔐