# Installation et Configuration Rails 7+

## Prérequis

### 1. Installation de Ruby (version 3.0+)
```bash
# Avec rbenv (recommandé)
brew install rbenv ruby-build
rbenv install 3.2.0
rbenv global 3.2.0

# Vérification
ruby -v  # Doit afficher Ruby 3.2.0
```

### 2. Installation de Rails 7+
```bash
gem install rails -v '~> 7.0'
rails -v  # Vérification
```

### 3. Base de données
```bash
# PostgreSQL (recommandé pour la production)
brew install postgresql
brew services start postgresql

# SQLite (par défaut, ok pour le développement)
# Déjà inclus avec Rails
```

## Création d'un nouveau projet Rails

### Application complète avec vues
```bash
rails new mon_app --database=postgresql
cd mon_app
bundle install
rails server
```

### API seulement (moderne)
```bash
rails new mon_api --api --database=postgresql
cd mon_api
bundle install
```

## Structure d'une application Rails 7

```
mon_app/
├── app/
│   ├── controllers/         # Logique de contrôle
│   ├── models/             # Modèles de données
│   ├── views/              # Templates HTML
│   ├── helpers/            # Méthodes d'aide pour les vues
│   ├── mailers/            # Gestion des emails
│   └── jobs/               # Tâches en arrière-plan
├── config/
│   ├── routes.rb           # Définition des routes
│   ├── database.yml        # Configuration BDD
│   └── application.rb      # Configuration app
├── db/
│   ├── migrate/            # Migrations de base de données
│   └── seeds.rb            # Données d'exemple
├── public/                 # Fichiers statiques
├── test/ ou spec/          # Tests
├── Gemfile                 # Dépendances Ruby
└── README.md
```

## Configuration moderne Rails 7

### Gemfile typique
```ruby
# Gemfile
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "rails", "~> 7.0"
gem "pg", "~> 1.1"              # PostgreSQL
gem "puma", "~> 5.0"            # Serveur web
gem "sass-rails", ">= 6"        # CSS
gem "webpacker", "~> 5.0"       # JavaScript
gem "turbo-rails"               # Turbo (nouveau dans Rails 7)
gem "stimulus-rails"            # Stimulus JS
gem "jbuilder", "~> 2.7"       # JSON APIs
gem "bootsnap", ">= 1.4.4", require: false

# Authentification moderne
gem "devise"

# Autorisation
gem "pundit"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  gem "web-console", ">= 4.1.0"
  gem "listen", "~> 3.3"
  gem "spring"
end
```

### Configuration de base
```ruby
# config/application.rb
require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module MonApp
  class Application < Rails::Application
    config.load_defaults 7.0

    # Configuration moderne
    config.api_only = false  # ou true pour une API
    config.time_zone = 'Paris'
    config.i18n.default_locale = :fr
  end
end
```

## Commandes utiles Rails

```bash
# Générer des composants
rails generate controller Articles index show
rails generate model Article title:string content:text
rails generate migration AddAuthorToArticles author:string

# Base de données
rails db:create      # Créer la BDD
rails db:migrate     # Exécuter les migrations
rails db:seed        # Charger les données d'exemple
rails db:reset       # Reset complet

# Console et serveur
rails console        # Console interactive
rails server         # Démarrer le serveur (port 3000)

# Tests
rails test          # Tests par défaut
rspec              # Si RSpec installé

# Routes
rails routes       # Voir toutes les routes
```

## Nouveautés Rails 7

### 1. Import Maps (remplace Webpacker)
```javascript
// app/javascript/application.js
import "@hotwired/turbo-rails"
import "@hotwired/stimulus"
```

### 2. Hotwire (Turbo + Stimulus)
- **Turbo**: Navigation rapide sans JavaScript
- **Stimulus**: JavaScript léger et structuré

### 3. CSS moderne
```scss
// app/assets/stylesheets/application.scss
@import "bootstrap";  // Si Bootstrap utilisé
```

## Premier contrôleur
```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

## Première vue
```erb
<!-- app/views/articles/index.html.erb -->
<h1>Articles</h1>

<% @articles.each do |article| %>
  <div class="article">
    <h2><%= link_to article.title, article_path(article) %></h2>
    <p><%= truncate(article.content, length: 100) %></p>
  </div>
<% end %>
```

## Routes de base
```ruby
# config/routes.rb
Rails.application.routes.draw do
  root 'articles#index'
  resources :articles
end
```

Cette configuration vous donne une base solide pour commencer avec Rails 7 ! 🚀