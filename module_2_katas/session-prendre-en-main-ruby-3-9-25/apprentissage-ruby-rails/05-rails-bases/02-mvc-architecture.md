# Architecture MVC dans Rails

## Qu'est-ce que MVC ?

**MVC** (Model-View-Controller) est un pattern architectural qui sépare une application en trois composants interconnectés :

- **Model** : Gère les données et la logique métier
- **View** : Gère l'affichage et l'interface utilisateur
- **Controller** : Fait le lien entre Model et View, gère les requêtes

## Le flux MVC dans Rails

```
Utilisateur → Routes → Controller → Model → Database
    ↑                      ↓
   View ←──────────────────┘
```

## 1. Routes (config/routes.rb)

Les routes définissent comment les URLs sont mappées vers les contrôleurs :

```ruby
# config/routes.rb
Rails.application.routes.draw do
  root 'home#index'                    # Page d'accueil

  resources :articles                  # Routes RESTful complètes
  # Équivalent à:
  # GET    /articles          → articles#index
  # GET    /articles/new      → articles#new
  # POST   /articles          → articles#create
  # GET    /articles/:id      → articles#show
  # GET    /articles/:id/edit → articles#edit
  # PATCH  /articles/:id      → articles#update
  # DELETE /articles/:id      → articles#destroy

  # Routes personnalisées
  get 'about', to: 'pages#about'
  post 'contact', to: 'messages#create'
end
```

## 2. Controllers (app/controllers/)

Les contrôleurs gèrent les requêtes HTTP et orchestrent les interactions :

```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  # GET /articles
  def index
    @articles = Article.published.recent  # Récupère les données
    # Rails rend automatiquement app/views/articles/index.html.erb
  end

  # GET /articles/:id
  def show
    # @article déjà défini par before_action
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # POST /articles
  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article, notice: 'Article créé avec succès!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /articles/:id/edit
  def edit
  end

  # PATCH /articles/:id
  def update
    if @article.update(article_params)
      redirect_to @article, notice: 'Article mis à jour!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /articles/:id
  def destroy
    @article.destroy
    redirect_to articles_path, notice: 'Article supprimé!'
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content, :published)
  end
end
```

## 3. Models (app/models/)

Les modèles gèrent les données et la logique métier :

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  # Validations
  validates :title, presence: true, length: { minimum: 5 }
  validates :content, presence: true, length: { minimum: 10 }

  # Relations
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many_attached :images  # Rails 7 - Active Storage

  # Scopes (requêtes réutilisables)
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_author, ->(author) { where(user: author) }

  # Méthodes d'instance
  def excerpt(limit = 100)
    content.truncate(limit)
  end

  def published?
    published
  end

  # Méthodes de classe
  def self.search(term)
    where("title ILIKE ? OR content ILIKE ?", "%#{term}%", "%#{term}%")
  end

  # Callbacks
  before_save :set_slug

  private

  def set_slug
    self.slug = title.parameterize if title.present?
  end
end
```

## 4. Views (app/views/)

Les vues gèrent l'affichage HTML :

```erb
<!-- app/views/articles/index.html.erb -->
<% content_for :title, "Articles" %>

<div class="articles-index">
  <div class="header">
    <h1>Tous les articles</h1>
    <%= link_to "Nouvel article", new_article_path, class: "btn btn-primary" %>
  </div>

  <div class="articles-grid">
    <% @articles.each do |article| %>
      <article class="article-card">
        <h2>
          <%= link_to article.title, article_path(article) %>
        </h2>

        <div class="meta">
          Par <%= article.user.name %> •
          <%= time_ago_in_words(article.created_at) %>
        </div>

        <p><%= article.excerpt %></p>

        <div class="actions">
          <%= link_to "Lire", article, class: "btn btn-secondary" %>
          <% if can?(:edit, article) %>
            <%= link_to "Modifier", edit_article_path(article), class: "btn btn-sm" %>
          <% end %>
        </div>
      </article>
    <% end %>
  </div>

  <% if @articles.empty? %>
    <div class="empty-state">
      <p>Aucun article publié pour le moment.</p>
      <%= link_to "Créer le premier article", new_article_path, class: "btn btn-primary" %>
    </div>
  <% end %>
</div>
```

## 5. Layouts et Partials

### Layout principal
```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>Mon Blog - <%= yield(:title) || "Accueil" %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body>
    <header>
      <%= render 'shared/navigation' %>
    </header>

    <main>
      <% if notice %>
        <div class="alert alert-success"><%= notice %></div>
      <% end %>

      <% if alert %>
        <div class="alert alert-danger"><%= alert %></div>
      <% end %>

      <%= yield %>
    </main>

    <footer>
      <%= render 'shared/footer' %>
    </footer>
  </body>
</html>
```

### Partial de navigation
```erb
<!-- app/views/shared/_navigation.html.erb -->
<nav class="navbar">
  <%= link_to "Mon Blog", root_path, class: "navbar-brand" %>

  <div class="navbar-nav">
    <%= link_to "Articles", articles_path %>
    <%= link_to "À propos", about_path %>

    <% if user_signed_in? %>
      <%= link_to "Nouveau", new_article_path %>
      <%= link_to "Profil", current_user %>
      <%= link_to "Déconnexion", destroy_user_session_path, method: :delete %>
    <% else %>
      <%= link_to "Connexion", new_user_session_path %>
    <% end %>
  </div>
</nav>
```

## 6. Helpers (app/helpers/)

Les helpers contiennent des méthodes utilitaires pour les vues :

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def page_title(title = nil)
    base_title = "Mon Blog"
    title.present? ? "#{title} | #{base_title}" : base_title
  end

  def flash_class(level)
    case level.to_s
    when 'notice' then 'alert-success'
    when 'alert' then 'alert-danger'
    when 'warning' then 'alert-warning'
    else 'alert-info'
    end
  end

  def markdown(text)
    return '' if text.blank?

    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text).html_safe
  end
end

# app/helpers/articles_helper.rb
module ArticlesHelper
  def article_status_badge(article)
    if article.published?
      content_tag :span, "Publié", class: "badge badge-success"
    else
      content_tag :span, "Brouillon", class: "badge badge-secondary"
    end
  end

  def reading_time(content)
    words = content.split.size
    minutes = (words / 200.0).ceil
    "#{minutes} min de lecture"
  end
end
```

## Bonnes pratiques MVC

### Controllers
- Gardez-les fins (fat models, skinny controllers)
- Une action = une responsabilité
- Utilisez les filtres (`before_action`, `after_action`)
- Gérez les erreurs proprement

### Models
- Toute la logique métier dans les models
- Utilisez les validations
- Créez des scopes réutilisables
- Utilisez les callbacks avec parcimonie

### Views
- Logique minimale dans les vues
- Utilisez des partials pour éviter la duplication
- Helpers pour la logique d'affichage
- Respectez la sémantique HTML

Cette architecture vous permet de créer des applications Rails maintenables et évolutives ! 🏗️