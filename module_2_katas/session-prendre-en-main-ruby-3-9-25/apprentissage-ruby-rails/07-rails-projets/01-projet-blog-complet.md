# Projet Complet : Blog Moderne avec Rails 7

## Vue d'ensemble du projet

Nous allons construire un blog moderne avec toutes les fonctionnalités actuelles :
- Authentication Devise
- Système de rôles
- Interface d'administration
- API REST
- Commentaires en temps réel
- Upload d'images
- SEO optimisé

## 1. Initialisation du projet

```bash
# Création du projet
rails new modern_blog --database=postgresql --css=tailwind
cd modern_blog

# Gems essentielles
```

### Gemfile complet
```ruby
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "rails", "~> 7.0"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "sass-rails", ">= 6"
gem "image_processing", "~> 1.2"
gem "redis", "~> 4.0"
gem "bootsnap", ">= 1.4.4", require: false

# UI et Assets
gem "tailwindcss-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder", "~> 2.7"

# Authentification et autorisation
gem "devise"
gem "pundit"

# Upload de fichiers
gem "image_processing", "~> 1.2"

# Pagination et recherche
gem "kaminari"
gem "ransack"

# Rich text editor
gem "trix-rails", require: "trix"

# SEO
gem "friendly_id"
gem "meta-tags"

# Markdown
gem "redcarpet"
gem "rouge"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console", ">= 4.1.0"
  gem "listen", "~> 3.3"
  gem "spring"
end

group :test do
  gem "capybara", ">= 3.26"
  gem "selenium-webdriver"
end
```

## 2. Configuration de base

### Application controller
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pundit::Authorization

  protect_from_forgery with: :exception
  before_action :authenticate_user!, except: [:show, :index]
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :username])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :username, :bio, :avatar])
  end

  def user_not_authorized
    flash[:alert] = "Vous n'êtes pas autorisé à effectuer cette action"
    redirect_back(fallback_location: root_path)
  end
end
```

## 3. Modèles de données

### User model
```ruby
# app/models/user.rb
class User < ApplicationRecord
  extend FriendlyId
  friendly_id :username, use: :slugged

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  # Associations
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one_attached :avatar

  # Validations
  validates :first_name, :last_name, presence: true
  validates :username, presence: true, uniqueness: true,
            format: { with: /\A[a-zA-Z0-9_]+\z/ }

  # Énumérations
  enum role: { user: 0, moderator: 1, admin: 2 }

  # Méthodes
  def full_name
    "#{first_name} #{last_name}"
  end

  def display_name
    username.presence || full_name
  end

  def avatar_url(size = :medium)
    if avatar.attached?
      case size
      when :small then avatar.variant(resize_to_limit: [50, 50])
      when :medium then avatar.variant(resize_to_limit: [100, 100])
      when :large then avatar.variant(resize_to_limit: [200, 200])
      end
    else
      "https://ui-avatars.com/api/?name=#{full_name}&background=random"
    end
  end

  def articles_count
    articles.published.count
  end

  def should_generate_new_friendly_id?
    username_changed? || super
  end
end
```

### Article model
```ruby
# app/models/article.rb
class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many_attached :images
  has_rich_text :content

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :excerpt, presence: true, length: { maximum: 300 }
  validates :status, inclusion: { in: %w[draft published archived] }

  # Scopes
  scope :published, -> { where(status: 'published', published_at: ..Time.current) }
  scope :recent, -> { order(published_at: :desc, created_at: :desc) }
  scope :by_author, ->(user) { where(user: user) }
  scope :featured, -> { where(featured: true) }

  # Callbacks
  before_save :set_published_at, if: :will_save_change_to_status?
  before_save :generate_reading_time

  def published?
    status == 'published' && published_at <= Time.current
  end

  def featured_image
    images.first if images.any?
  end

  def previous_article
    user.articles.published
        .where('published_at < ?', published_at)
        .order(published_at: :desc)
        .first
  end

  def next_article
    user.articles.published
        .where('published_at > ?', published_at)
        .order(published_at: :asc)
        .first
  end

  def related_articles(limit = 3)
    Article.published
           .where.not(id: id)
           .limit(limit)
           .sample(limit)
  end

  private

  def set_published_at
    if status == 'published' && published_at.blank?
      self.published_at = Time.current
    end
  end

  def generate_reading_time
    words = content.to_plain_text.split.size
    self.reading_time = (words / 200.0).ceil
  end

  def should_generate_new_friendly_id?
    title_changed? || super
  end
end
```

### Comment model
```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'parent_id', dependent: :destroy

  validates :content, presence: true, length: { minimum: 3, maximum: 1000 }
  validates :status, inclusion: { in: %w[pending approved rejected] }

  scope :approved, -> { where(status: 'approved') }
  scope :pending, -> { where(status: 'pending') }
  scope :root_comments, -> { where(parent_id: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def approved?
    status == 'approved'
  end

  def pending?
    status == 'pending'
  end

  def depth
    parent ? parent.depth + 1 : 0
  end
end
```

## 4. Contrôleurs principaux

### Articles controller
```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    @q = Article.published.includes(:user).ransack(params[:q])
    @articles = @q.result
                  .page(params[:page])
                  .per(12)

    @featured_articles = Article.featured.published.limit(3) if params[:page].blank?

    # SEO
    set_meta_tags title: "Blog",
                  description: "Découvrez nos derniers articles",
                  keywords: "blog, articles, actualités"
  end

  def show
    authorize @article

    unless @article.published? || (@article.user == current_user)
      redirect_to articles_path, alert: "Article non trouvé"
      return
    end

    @comment = Comment.new
    @comments = @article.comments.approved.root_comments.includes(:user, :replies)

    # SEO
    set_meta_tags title: @article.title,
                  description: @article.excerpt,
                  keywords: @article.tags&.join(", "),
                  og: {
                    title: @article.title,
                    description: @article.excerpt,
                    image: @article.featured_image&.url
                  }

    # Analytics
    @article.increment!(:views_count)
  end

  def new
    @article = current_user.articles.build
    authorize @article
  end

  def create
    @article = current_user.articles.build(article_params)
    authorize @article

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article créé avec succès!' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    authorize @article
  end

  def update
    authorize @article

    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: 'Article mis à jour!' }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @article
    @article.destroy

    respond_to do |format|
      format.html { redirect_to articles_path, notice: 'Article supprimé' }
      format.turbo_stream
    end
  end

  private

  def set_article
    @article = Article.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to articles_path, alert: "Article non trouvé"
  end

  def article_params
    params.require(:article).permit(:title, :excerpt, :content, :status, :featured, images: [])
  end
end
```

### Comments controller
```ruby
# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article
  before_action :set_comment, only: [:show, :edit, :update, :destroy, :approve, :reject]

  def create
    @comment = @article.comments.build(comment_params)
    @comment.user = current_user
    @comment.status = current_user.admin? ? 'approved' : 'pending'

    respond_to do |format|
      if @comment.save
        format.turbo_stream do
          if @comment.approved?
            render turbo_stream: [
              turbo_stream.prepend("comments", partial: "comments/comment", locals: { comment: @comment }),
              turbo_stream.replace("comment_form", partial: "comments/form", locals: { comment: Comment.new })
            ]
          else
            render turbo_stream: turbo_stream.replace("comment_form",
                   partial: "comments/pending_message")
          end
        end
        format.html { redirect_to @article }
      else
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { redirect_to @article, alert: 'Erreur lors de la création du commentaire' }
      end
    end
  end

  def edit
    authorize @comment
  end

  def update
    authorize @comment

    respond_to do |format|
      if @comment.update(comment_params)
        format.turbo_stream
        format.html { redirect_to @article }
      else
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.html { redirect_to @article }
      end
    end
  end

  def destroy
    authorize @comment

    respond_to do |format|
      @comment.destroy
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@comment) }
      format.html { redirect_to @article }
    end
  end

  # Actions admin
  def approve
    authorize @comment, :moderate?
    @comment.update(status: 'approved')

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: admin_comments_path) }
    end
  end

  def reject
    authorize @comment, :moderate?
    @comment.update(status: 'rejected')

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: admin_comments_path) }
    end
  end

  private

  def set_article
    @article = Article.friendly.find(params[:article_id])
  end

  def set_comment
    @comment = @article.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end
end
```

## 5. Policies Pundit

### Article Policy
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

### Comment Policy
```ruby
# app/policies/comment_policy.rb
class CommentPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  def update?
    owner?
  end

  def destroy?
    owner? || admin?
  end

  def moderate?
    admin? || moderator?
  end

  private

  def owner?
    user == record.user
  end

  def admin?
    user&.admin?
  end

  def moderator?
    user&.moderator?
  end
end
```

## 6. Vues avec Tailwind CSS

### Layout principal
```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title><%= yield(:title) || "Modern Blog" %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= display_meta_tags %>

    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="bg-gray-50 min-h-screen">
    <header class="bg-white shadow">
      <nav class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <div class="flex-shrink-0 flex items-center">
              <%= link_to "ModernBlog", root_path,
                  class: "text-xl font-bold text-gray-900" %>
            </div>

            <div class="ml-6 flex space-x-8">
              <%= link_to "Articles", articles_path,
                  class: "text-gray-500 hover:text-gray-900 px-3 py-2 rounded-md" %>
            </div>
          </div>

          <div class="flex items-center space-x-4">
            <% if user_signed_in? %>
              <%= link_to "Nouvel article", new_article_path,
                  class: "bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700" %>

              <div class="relative" data-controller="dropdown">
                <button data-action="click->dropdown#toggle"
                        class="flex items-center space-x-2 text-gray-700">
                  <%= image_tag current_user.avatar_url(:small),
                      class: "w-8 h-8 rounded-full" %>
                  <span><%= current_user.display_name %></span>
                </button>

                <div data-dropdown-target="menu"
                     class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg hidden">
                  <%= link_to "Mon profil", user_path(current_user),
                      class: "block px-4 py-2 text-gray-700 hover:bg-gray-100" %>
                  <%= link_to "Paramètres", edit_user_registration_path,
                      class: "block px-4 py-2 text-gray-700 hover:bg-gray-100" %>
                  <% if current_user.admin? %>
                    <%= link_to "Administration", admin_root_path,
                        class: "block px-4 py-2 text-gray-700 hover:bg-gray-100" %>
                  <% end %>
                  <hr class="my-2">
                  <%= link_to "Déconnexion", destroy_user_session_path,
                      method: :delete,
                      class: "block px-4 py-2 text-gray-700 hover:bg-gray-100" %>
                </div>
              </div>
            <% else %>
              <%= link_to "Connexion", new_user_session_path,
                  class: "text-gray-500 hover:text-gray-900" %>
              <%= link_to "Inscription", new_user_registration_path,
                  class: "bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700" %>
            <% end %>
          </div>
        </div>
      </nav>
    </header>

    <main class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
      <% if notice %>
        <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
          <%= notice %>
        </div>
      <% end %>

      <% if alert %>
        <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
          <%= alert %>
        </div>
      <% end %>

      <div id="flash-messages"></div>

      <%= yield %>
    </main>

    <footer class="bg-gray-800 text-white mt-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div class="text-center">
          <p>&copy; 2024 Modern Blog. Tous droits réservés.</p>
        </div>
      </div>
    </footer>
  </body>
</html>
```

Ce projet complet vous donne une base solide pour un blog moderne avec Rails 7 ! 🚀

**Prochaines étapes** :
- Interface d'administration
- API REST complète
- Tests complets
- Déploiement