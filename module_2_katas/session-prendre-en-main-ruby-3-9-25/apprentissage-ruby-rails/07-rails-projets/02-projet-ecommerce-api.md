# Projet E-commerce API avec Rails 7

## Vue d'ensemble

Création d'une API REST moderne pour un système e-commerce avec :
- Gestion des produits et catégories
- Panier d'achat et commandes
- Système de paiement
- Gestion des stocks
- API complète avec authentification JWT

## 1. Structure du projet

```bash
rails new ecommerce_api --api --database=postgresql
cd ecommerce_api
```

### Gemfile
```ruby
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "rails", "~> 7.0"
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
gem "bootsnap", ">= 1.4.4", require: false

# API essentials
gem "rack-cors"
gem "jbuilder"
gem "kaminari"
gem "ransack"

# Authentication
gem "jwt"
gem "bcrypt", "~> 3.1.7"

# Images
gem "image_processing", "~> 1.2"

# Serialization
gem "jsonapi-serializer"

# Background jobs
gem "sidekiq"
gem "redis", "~> 4.0"

# Payment
gem "stripe"

# Money handling
gem "money-rails"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "listen", "~> 3.3"
  gem "spring"
end

group :test do
  gem "shoulda-matchers", "~> 5.0"
  gem "database_cleaner-active_record"
end
```

## 2. Modèles de données

### User model
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_secure_token :api_token

  # Associations
  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_one_attached :avatar

  # Validations
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true
  validates :phone, presence: true

  # Énumérations
  enum role: { customer: 0, admin: 1, manager: 2 }

  # Callbacks
  after_create :create_cart

  def full_name
    "#{first_name} #{last_name}"
  end

  def regenerate_api_token!
    regenerate_api_token
    save!
  end

  private

  def create_cart
    Cart.create!(user: self)
  end
end
```

### Category model
```ruby
# app/models/category.rb
class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Category', optional: true

  validates :name, presence: true, uniqueness: { scope: :parent_id }
  validates :slug, presence: true, uniqueness: true

  scope :root_categories, -> { where(parent_id: nil) }
  scope :active, -> { where(active: true) }

  before_validation :generate_slug

  def root?
    parent_id.nil?
  end

  def has_subcategories?
    subcategories.any?
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
```

### Product model
```ruby
# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :category
  has_many :product_variants, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :product_images, dependent: :destroy
  has_many_attached :images

  # Money fields
  monetize :price_cents

  # Validations
  validates :name, presence: true
  validates :description, presence: true
  validates :price_cents, presence: true, numericality: { greater_than: 0 }
  validates :sku, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where('stock_quantity > 0') }
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(category) { where(category: category) }

  # Callbacks
  before_validation :generate_slug

  def in_stock?
    stock_quantity > 0
  end

  def featured_image
    images.first if images.any?
  end

  def can_order?(quantity = 1)
    active? && stock_quantity >= quantity
  end

  def reduce_stock!(quantity)
    update!(stock_quantity: stock_quantity - quantity) if can_order?(quantity)
  end

  def restore_stock!(quantity)
    update!(stock_quantity: stock_quantity + quantity)
  end

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
```

### Cart model
```ruby
# app/models/cart.rb
class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  def total_price
    cart_items.sum { |item| item.product.price * item.quantity }
  end

  def total_items
    cart_items.sum(:quantity)
  end

  def add_item(product, quantity = 1)
    existing_item = cart_items.find_by(product: product)

    if existing_item
      existing_item.update!(quantity: existing_item.quantity + quantity)
    else
      cart_items.create!(product: product, quantity: quantity)
    end
  end

  def remove_item(product)
    cart_items.find_by(product: product)&.destroy
  end

  def update_item_quantity(product, quantity)
    item = cart_items.find_by(product: product)
    return unless item

    if quantity <= 0
      item.destroy
    else
      item.update!(quantity: quantity)
    end
  end

  def clear
    cart_items.destroy_all
  end

  def empty?
    cart_items.empty?
  end
end
```

### Order model
```ruby
# app/models/order.rb
class Order < ApplicationRecord
  belongs_to :user
  belongs_to :billing_address, class_name: 'Address'
  belongs_to :shipping_address, class_name: 'Address'
  has_many :order_items, dependent: :destroy

  # Money fields
  monetize :subtotal_cents
  monetize :tax_cents
  monetize :shipping_cents
  monetize :total_cents

  # Validations
  validates :order_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: %w[pending confirmed processing shipped delivered cancelled] }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  # Callbacks
  before_validation :generate_order_number, on: :create
  after_create :reduce_stock

  enum status: {
    pending: 0,
    confirmed: 1,
    processing: 2,
    shipped: 3,
    delivered: 4,
    cancelled: 5
  }

  def self.create_from_cart(user, billing_address, shipping_address, cart)
    transaction do
      order = create!(
        user: user,
        billing_address: billing_address,
        shipping_address: shipping_address,
        subtotal: cart.total_price,
        tax: calculate_tax(cart.total_price),
        shipping: calculate_shipping(cart.total_price),
        status: 'pending'
      )

      order.total = order.subtotal + order.tax + order.shipping

      cart.cart_items.each do |cart_item|
        order.order_items.create!(
          product: cart_item.product,
          quantity: cart_item.quantity,
          price: cart_item.product.price
        )
      end

      cart.clear
      order.save!
      order
    end
  end

  def can_be_cancelled?
    %w[pending confirmed].include?(status)
  end

  def cancel!
    return unless can_be_cancelled?

    transaction do
      update!(status: 'cancelled')
      restore_stock
    end
  end

  private

  def generate_order_number
    self.order_number = "ORD-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def self.calculate_tax(subtotal)
    subtotal * 0.20 # 20% TVA
  end

  def self.calculate_shipping(subtotal)
    subtotal > Money.new(5000, 'EUR') ? Money.new(0, 'EUR') : Money.new(590, 'EUR') # Gratuit > 50€
  end

  def reduce_stock
    order_items.each do |item|
      item.product.reduce_stock!(item.quantity)
    end
  end

  def restore_stock
    order_items.each do |item|
      item.product.restore_stock!(item.quantity)
    end
  end
end
```

## 3. Contrôleurs API

### Base API Controller
```ruby
# app/controllers/api/v1/base_controller.rb
class Api::V1::BaseController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_request
  before_action :set_default_format

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  protected

  def current_user
    @current_user
  end

  def authenticate_request
    authenticate_token || render_unauthorized
  end

  def authenticate_token
    authenticate_with_http_token do |token, _options|
      @current_user = User.find_by(api_token: token)
    end
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  def set_default_format
    request.format = :json
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

  private

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

### Products Controller
```ruby
# app/controllers/api/v1/products_controller.rb
class Api::V1::ProductsController < Api::V1::BaseController
  skip_before_action :authenticate_request, only: [:index, :show]
  before_action :set_product, only: [:show, :update, :destroy]

  def index
    @q = Product.active.includes(:category).ransack(params[:q])
    @products = @q.result
                  .page(params[:page])
                  .per(params[:per_page] || 20)

    # Filtres spéciaux
    @products = @products.by_category(params[:category_id]) if params[:category_id]
    @products = @products.featured if params[:featured] == 'true'
    @products = @products.in_stock if params[:in_stock] == 'true'

    render json: {
      products: ProductSerializer.new(@products).serializable_hash[:data],
      meta: pagination_meta(@products),
      filters: {
        categories: CategorySerializer.new(Category.active.root_categories).serializable_hash[:data]
      }
    }
  end

  def show
    render json: {
      product: ProductSerializer.new(@product, include: [:category]).serializable_hash[:data]
    }
  end

  def create
    return render_unauthorized unless current_user&.admin?

    @product = Product.new(product_params)

    if @product.save
      render json: {
        product: ProductSerializer.new(@product).serializable_hash[:data]
      }, status: :created
    else
      render json: {
        error: 'Product creation failed',
        details: @product.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def update
    return render_unauthorized unless current_user&.admin?

    if @product.update(product_params)
      render json: {
        product: ProductSerializer.new(@product).serializable_hash[:data]
      }
    else
      render json: {
        error: 'Product update failed',
        details: @product.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def destroy
    return render_unauthorized unless current_user&.admin?

    @product.destroy
    head :no_content
  end

  private

  def set_product
    @product = Product.find_by!(slug: params[:id]) || Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :category_id,
                                   :stock_quantity, :sku, :active, :featured,
                                   images: [])
  end
end
```

### Cart Controller
```ruby
# app/controllers/api/v1/cart_controller.rb
class Api::V1::CartController < Api::V1::BaseController
  before_action :set_cart

  def show
    render json: {
      cart: CartSerializer.new(@cart, include: [:cart_items]).serializable_hash[:data]
    }
  end

  def add_item
    product = Product.find(params[:product_id])
    quantity = params[:quantity]&.to_i || 1

    unless product.can_order?(quantity)
      return render json: {
        error: 'Product not available',
        message: 'Insufficient stock or inactive product'
      }, status: :unprocessable_entity
    end

    @cart.add_item(product, quantity)

    render json: {
      cart: CartSerializer.new(@cart.reload, include: [:cart_items]).serializable_hash[:data],
      message: 'Item added to cart'
    }
  end

  def remove_item
    product = Product.find(params[:product_id])
    @cart.remove_item(product)

    render json: {
      cart: CartSerializer.new(@cart.reload, include: [:cart_items]).serializable_hash[:data],
      message: 'Item removed from cart'
    }
  end

  def update_item
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    unless product.can_order?(quantity)
      return render json: {
        error: 'Invalid quantity',
        message: 'Insufficient stock'
      }, status: :unprocessable_entity
    end

    @cart.update_item_quantity(product, quantity)

    render json: {
      cart: CartSerializer.new(@cart.reload, include: [:cart_items]).serializable_hash[:data],
      message: 'Cart updated'
    }
  end

  def clear
    @cart.clear

    render json: {
      cart: CartSerializer.new(@cart.reload).serializable_hash[:data],
      message: 'Cart cleared'
    }
  end

  private

  def set_cart
    @cart = current_user.cart
  end
end
```

### Orders Controller
```ruby
# app/controllers/api/v1/orders_controller.rb
class Api::V1::OrdersController < Api::V1::BaseController
  before_action :set_order, only: [:show, :cancel]

  def index
    @orders = current_user.orders
                          .includes(:order_items, :billing_address, :shipping_address)
                          .recent
                          .page(params[:page])
                          .per(params[:per_page] || 10)

    render json: {
      orders: OrderSerializer.new(@orders).serializable_hash[:data],
      meta: pagination_meta(@orders)
    }
  end

  def show
    render json: {
      order: OrderSerializer.new(@order, include: [:order_items, :billing_address, :shipping_address]).serializable_hash[:data]
    }
  end

  def create
    cart = current_user.cart

    if cart.empty?
      return render json: {
        error: 'Empty cart',
        message: 'Cannot create order from empty cart'
      }, status: :unprocessable_entity
    end

    # Vérifier la disponibilité des produits
    cart.cart_items.each do |item|
      unless item.product.can_order?(item.quantity)
        return render json: {
          error: 'Product unavailable',
          message: "#{item.product.name} is not available in requested quantity"
        }, status: :unprocessable_entity
      end
    end

    billing_address = find_or_create_address(order_params[:billing_address])
    shipping_address = find_or_create_address(order_params[:shipping_address])

    begin
      @order = Order.create_from_cart(current_user, billing_address, shipping_address, cart)

      # Traitement du paiement (simulé)
      payment_result = process_payment(@order, order_params[:payment_method])

      if payment_result[:success]
        @order.update!(status: 'confirmed', payment_status: 'paid')

        render json: {
          order: OrderSerializer.new(@order).serializable_hash[:data],
          message: 'Order created successfully'
        }, status: :created
      else
        @order.cancel!

        render json: {
          error: 'Payment failed',
          message: payment_result[:error]
        }, status: :payment_required
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: {
        error: 'Order creation failed',
        details: e.record.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def cancel
    if @order.can_be_cancelled?
      @order.cancel!
      render json: {
        order: OrderSerializer.new(@order).serializable_hash[:data],
        message: 'Order cancelled successfully'
      }
    else
      render json: {
        error: 'Cannot cancel order',
        message: 'Order cannot be cancelled in current status'
      }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :payment_method,
      billing_address: [:first_name, :last_name, :street, :city, :postal_code, :country],
      shipping_address: [:first_name, :last_name, :street, :city, :postal_code, :country]
    )
  end

  def find_or_create_address(address_params)
    # Logique pour trouver ou créer une adresse
    Address.find_or_create_by(address_params.merge(user: current_user))
  end

  def process_payment(order, payment_method)
    # Intégration Stripe ou autre processeur de paiement
    # Pour la démo, on simule un paiement réussi
    {
      success: true,
      transaction_id: SecureRandom.hex(8)
    }
  rescue StandardError => e
    {
      success: false,
      error: e.message
    }
  end
end
```

## 4. Serializers

### Product Serializer
```ruby
# app/serializers/product_serializer.rb
class ProductSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :price, :sku, :stock_quantity, :slug, :active, :featured

  attribute :price_formatted do |product|
    product.price.format
  end

  attribute :in_stock do |product|
    product.in_stock?
  end

  attribute :images do |product|
    product.images.map do |image|
      {
        url: Rails.application.routes.url_helpers.rails_blob_url(image),
        thumbnail: Rails.application.routes.url_helpers.rails_representation_url(
          image.variant(resize_to_limit: [300, 300])
        )
      }
    end
  end

  belongs_to :category
end
```

### Cart Serializer
```ruby
# app/serializers/cart_serializer.rb
class CartSerializer
  include JSONAPI::Serializer

  attributes :created_at, :updated_at

  attribute :total_price do |cart|
    cart.total_price.format
  end

  attribute :total_items do |cart|
    cart.total_items
  end

  attribute :empty do |cart|
    cart.empty?
  end

  has_many :cart_items
end
```

## 5. Tests RSpec

### Product model test
```ruby
# spec/models/product_spec.rb
require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'associations' do
    it { should belong_to(:category) }
    it { should have_many(:cart_items) }
    it { should have_many(:order_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price_cents) }
    it { should validate_uniqueness_of(:sku) }
  end

  describe 'scopes' do
    let!(:active_product) { create(:product, active: true) }
    let!(:inactive_product) { create(:product, active: false) }

    it 'returns only active products' do
      expect(Product.active).to include(active_product)
      expect(Product.active).not_to include(inactive_product)
    end
  end

  describe '#can_order?' do
    let(:product) { create(:product, stock_quantity: 5) }

    it 'returns true when enough stock' do
      expect(product.can_order?(3)).to be true
    end

    it 'returns false when insufficient stock' do
      expect(product.can_order?(10)).to be false
    end
  end
end
```

Cette API e-commerce moderne vous donne une base complète pour construire un système de vente en ligne robuste ! 🛒