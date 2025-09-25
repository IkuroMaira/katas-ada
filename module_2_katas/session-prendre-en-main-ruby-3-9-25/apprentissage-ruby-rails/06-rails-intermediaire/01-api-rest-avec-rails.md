# API REST avec Rails 7

## Introduction aux APIs REST

Une API REST (Representational State Transfer) permet aux applications de communiquer entre elles via HTTP. Rails 7 facilite grandement la création d'APIs modernes.

## 1. Création d'une API Rails

### Nouvelle application API
```bash
rails new blog_api --api --database=postgresql
cd blog_api
```

### Gemfile pour API moderne
```ruby
# Gemfile
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "rails", "~> 7.0"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"

# API essentials
gem "bootsnap", ">= 1.4.4", require: false
gem "rack-cors"                    # CORS
gem "jbuilder"                     # JSON builders
gem "kaminari"                     # Pagination
gem "ransack"                      # Search & filtering

# Authentication
gem "jwt"
gem "bcrypt", "~> 3.1.7"

# Serialization
gem "jsonapi-serializer"           # JSON:API format

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  gem "listen", "~> 3.3"
  gem "spring"
end
```

## 2. Configuration CORS

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', 'localhost:8080', '127.0.0.1:3000'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

## 3. Structure des contrôleurs API

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_request
  before_action :set_default_format

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def set_default_format
    request.format = :json
  end

  def authenticate_request
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, _options|
      @current_user = User.find_by(api_token: token)
    end
  end

  def current_user
    @current_user
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def record_not_found(exception)
    render json: {
      error: 'Resource not found',
      message: exception.message
    }, status: :not_found
  end

  def record_invalid(exception)
    render json: {
      error: 'Validation failed',
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def parameter_missing(exception)
    render json: {
      error: 'Missing parameter',
      message: exception.message
    }, status: :bad_request
  end
end
```

## 4. Modèles avec validations

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_secure_token :api_token

  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }

  scope :active, -> { where(active: true) }

  def regenerate_api_token!
    regenerate_api_token
    save!
  end
end

# app/models/article.rb
class Article < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many_attached :images

  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :status, inclusion: { in: %w[draft published archived] }

  scope :published, -> { where(status: 'published') }
  scope :by_author, ->(user) { where(user: user) }
  scope :recent, -> { order(created_at: :desc) }

  def published?
    status == 'published'
  end

  def excerpt(limit = 150)
    content.truncate(limit)
  end
end

# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :article
  belongs_to :user

  validates :content, presence: true, length: { minimum: 3, maximum: 1000 }
  validates :status, inclusion: { in: %w[pending approved rejected] }

  scope :approved, -> { where(status: 'approved') }
  scope :recent, -> { order(created_at: :desc) }
end
```

## 5. Contrôleur API complet

```ruby
# app/controllers/api/v1/articles_controller.rb
class Api::V1::ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :update, :destroy]
  before_action :check_owner, only: [:update, :destroy]

  # GET /api/v1/articles
  def index
    @articles = Article.published
                      .includes(:user, :comments)
                      .page(params[:page])
                      .per(params[:per_page] || 10)

    # Filtrage avec Ransack
    @articles = @articles.ransack(params[:q]).result if params[:q]

    render json: {
      articles: ArticleSerializer.new(@articles).serializable_hash[:data],
      meta: pagination_meta(@articles),
      links: pagination_links(@articles)
    }
  end

  # GET /api/v1/articles/:id
  def show
    render json: {
      article: ArticleSerializer.new(@article, include: [:user, :comments]).serializable_hash[:data]
    }
  end

  # POST /api/v1/articles
  def create
    @article = current_user.articles.build(article_params)

    if @article.save
      render json: {
        article: ArticleSerializer.new(@article).serializable_hash[:data]
      }, status: :created
    else
      render json: {
        error: 'Article creation failed',
        details: @article.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/articles/:id
  def update
    if @article.update(article_params)
      render json: {
        article: ArticleSerializer.new(@article).serializable_hash[:data]
      }
    else
      render json: {
        error: 'Article update failed',
        details: @article.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/articles/:id
  def destroy
    @article.destroy
    head :no_content
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def check_owner
    render_unauthorized unless @article.user == current_user
  end

  def article_params
    params.require(:article).permit(:title, :content, :status, images: [])
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end

  def pagination_links(collection)
    {
      self: request.url,
      first: api_v1_articles_url(page: 1),
      last: api_v1_articles_url(page: collection.total_pages),
      next: collection.next_page ? api_v1_articles_url(page: collection.next_page) : nil,
      prev: collection.prev_page ? api_v1_articles_url(page: collection.prev_page) : nil
    }
  end
end
```

## 6. Serializers JSON

```ruby
# app/serializers/article_serializer.rb
class ArticleSerializer
  include JSONAPI::Serializer

  attributes :title, :content, :status, :created_at, :updated_at

  attribute :excerpt do |article|
    article.excerpt(100)
  end

  attribute :reading_time do |article|
    (article.content.split.size / 200.0).ceil
  end

  belongs_to :user
  has_many :comments

  meta do |article|
    { comments_count: article.comments.approved.count }
  end
end

# app/serializers/user_serializer.rb
class UserSerializer
  include JSONAPI::Serializer

  attributes :name, :email, :created_at

  # Ne pas exposer les données sensibles
  attribute :avatar_url do |user|
    user.avatar.attached? ? Rails.application.routes.url_helpers.rails_blob_url(user.avatar) : nil
  end
end

# app/serializers/comment_serializer.rb
class CommentSerializer
  include JSONAPI::Serializer

  attributes :content, :status, :created_at

  belongs_to :user
  belongs_to :article
end
```

## 7. Routes API versionées

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :articles do
        resources :comments, except: [:show]
      end

      resources :users, only: [:show, :create, :update] do
        member do
          post :regenerate_token
        end
      end

      post 'auth/login', to: 'authentication#login'
      post 'auth/logout', to: 'authentication#logout'
      get 'auth/verify', to: 'authentication#verify'
    end
  end

  # Route de santé pour monitoring
  get '/health', to: 'health#check'
end
```

## 8. Authentification JWT

```ruby
# app/controllers/api/v1/authentication_controller.rb
class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [:login]

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      render json: {
        user: UserSerializer.new(user).serializable_hash[:data],
        token: user.api_token
      }
    else
      render json: {
        error: 'Invalid credentials'
      }, status: :unauthorized
    end
  end

  def logout
    current_user.regenerate_api_token!
    head :no_content
  end

  def verify
    render json: {
      user: UserSerializer.new(current_user).serializable_hash[:data]
    }
  end
end
```

## 9. Tests API avec RSpec

```ruby
# spec/requests/api/v1/articles_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Articles', type: :request do
  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Token #{user.api_token}" } }

  describe 'GET /api/v1/articles' do
    let!(:articles) { create_list(:article, 3, status: 'published') }

    it 'returns published articles' do
      get '/api/v1/articles', headers: headers

      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['articles'].size).to eq(3)
    end

    it 'supports pagination' do
      get '/api/v1/articles?page=1&per_page=2', headers: headers

      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body['articles'].size).to eq(2)
      expect(body['meta']['total_count']).to eq(3)
    end
  end

  describe 'POST /api/v1/articles' do
    let(:article_params) do
      {
        article: {
          title: 'New Article',
          content: 'Content of the new article',
          status: 'published'
        }
      }
    end

    it 'creates a new article' do
      expect {
        post '/api/v1/articles', params: article_params, headers: headers
      }.to change(Article, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'returns validation errors for invalid data' do
      article_params[:article][:title] = ''

      post '/api/v1/articles', params: article_params, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('Article creation failed')
    end
  end
end
```

## 10. Documentation API avec rswag

```ruby
# spec/swagger_helper.rb
require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s

  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Blog API V1',
        version: 'v1',
        description: 'API REST pour un blog moderne'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: 'http',
            scheme: 'bearer'
          }
        }
      }
    }
  }

  config.swagger_format = :yaml
end
```

Cette architecture API moderne vous donne une base solide pour créer des APIs REST performantes et sécurisées avec Rails 7 ! 🚀