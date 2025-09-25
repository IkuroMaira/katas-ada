# Hotwire : Turbo & Stimulus avec Rails 7

## Introduction à Hotwire

**Hotwire** (HTML Over The Wire) est l'approche moderne de Rails 7 pour créer des applications web interactives sans écrire beaucoup de JavaScript. Il se compose de **Turbo** et **Stimulus**.

## 1. Turbo - Navigation rapide

### Configuration de base
```ruby
# Gemfile (inclus par défaut dans Rails 7)
gem 'turbo-rails'

# app/javascript/application.js
import "@hotwired/turbo-rails"

// Configuration globale
Turbo.session.drive = true
```

### Turbo Drive - Navigation SPA-like
```erb
<!-- Navigation automatiquement accélérée -->
<nav>
  <%= link_to "Accueil", root_path %>
  <%= link_to "Articles", articles_path %>
  <%= link_to "À propos", about_path %>
</nav>

<!-- Désactiver Turbo pour certains liens -->
<%= link_to "Télécharger PDF", document_path, data: { turbo: false } %>

<!-- Forcer le rechargement complet -->
<%= link_to "Admin", admin_path, data: { turbo_method: :get, turbo_action: "replace" } %>
```

### Turbo Frames - Mise à jour partielle
```erb
<!-- Vue principale avec frame -->
<!-- app/views/articles/index.html.erb -->
<div class="articles-container">
  <h1>Articles</h1>

  <!-- Frame pour la liste des articles -->
  <%= turbo_frame_tag "articles_list" do %>
    <div class="articles-grid">
      <% @articles.each do |article| %>
        <%= turbo_frame_tag "article_#{article.id}", class: "article-card" do %>
          <h3><%= link_to article.title, article_path(article) %></h3>
          <p><%= article.excerpt %></p>
          <div class="actions">
            <%= link_to "Modifier", edit_article_path(article) %>
            <%= link_to "Supprimer", article_path(article),
                        method: :delete,
                        data: {
                          turbo_method: :delete,
                          turbo_confirm: "Êtes-vous sûr ?"
                        } %>
          </div>
        <% end %>
      <% end %>
    </div>
  <% end %>

  <!-- Formulaire d'ajout dans un autre frame -->
  <%= turbo_frame_tag "new_article_form" do %>
    <%= link_to "Nouvel article", new_article_path, class: "btn btn-primary" %>
  <% end %>
</div>
```

```erb
<!-- Formulaire qui se charge dans le frame -->
<!-- app/views/articles/new.html.erb -->
<%= turbo_frame_tag "new_article_form" do %>
  <div class="form-container">
    <h2>Nouvel Article</h2>

    <%= form_with model: @article, local: true do |form| %>
      <div class="form-group">
        <%= form.label :title %>
        <%= form.text_field :title, class: "form-control" %>
      </div>

      <div class="form-group">
        <%= form.label :content %>
        <%= form.text_area :content, class: "form-control", rows: 10 %>
      </div>

      <div class="form-actions">
        <%= form.submit "Créer", class: "btn btn-success" %>
        <%= link_to "Annuler", articles_path, class: "btn btn-secondary" %>
      </div>
    <% end %>
  </div>
<% end %>
```

### Turbo Streams - Mise à jour en temps réel
```ruby
# app/controllers/articles_controller.rb
class ArticlesController < ApplicationController
  def create
    @article = Article.new(article_params)

    respond_to do |format|
      if @article.save
        format.turbo_stream do
          render turbo_stream: [
            # Ajouter le nouvel article à la liste
            turbo_stream.prepend("articles_list",
                                partial: "article",
                                locals: { article: @article }),
            # Réinitialiser le formulaire
            turbo_stream.replace("new_article_form",
                                partial: "new_article_button"),
            # Afficher un message de succès
            turbo_stream.prepend("flash_messages",
                                partial: "shared/flash",
                                locals: { message: "Article créé !", type: "success" })
          ]
        end
        format.html { redirect_to @article }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("new_article_form",
                                                   partial: "form",
                                                   locals: { article: @article })
        end
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("article_#{@article.id}"),
          turbo_stream.prepend("flash_messages",
                              partial: "shared/flash",
                              locals: { message: "Article supprimé", type: "info" })
        ]
      end
      format.html { redirect_to articles_path }
    end
  end
end
```

### Templates Turbo Stream
```erb
<!-- app/views/articles/create.turbo_stream.erb -->
<%= turbo_stream.prepend "articles_list" do %>
  <%= render "article", article: @article %>
<% end %>

<%= turbo_stream.replace "new_article_form" do %>
  <%= render "new_article_button" %>
<% end %>

<%= turbo_stream.prepend "flash_messages" do %>
  <div class="alert alert-success alert-dismissible">
    Article créé avec succès !
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
<% end %>
```

## 2. Stimulus - JavaScript structuré

### Configuration et premier contrôleur
```javascript
// app/javascript/controllers/application.js
import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

const application = Application.start()
const context = require.context("./", true, /\.js$/)
application.load(definitionsFromContext(context))

export { application }
```

### Contrôleur Stimulus pour modal
```javascript
// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "body"]
  static classes = ["open"]
  static values = {
    backdrop: { type: Boolean, default: true },
    keyboard: { type: Boolean, default: true }
  }

  connect() {
    // Fermer avec Escape
    if (this.keyboardValue) {
      this.boundHandleKeydown = this.handleKeydown.bind(this)
      document.addEventListener("keydown", this.boundHandleKeydown)
    }
  }

  disconnect() {
    if (this.boundHandleKeydown) {
      document.removeEventListener("keydown", this.boundHandleKeydown)
    }
  }

  open() {
    this.modalTarget.classList.add(this.openClass)
    this.bodyTarget.style.overflow = "hidden"

    // Focus sur le modal
    this.modalTarget.focus()

    // Event personnalisé
    this.dispatch("opened", { detail: { modal: this.modalTarget } })
  }

  close() {
    this.modalTarget.classList.remove(this.openClass)
    this.bodyTarget.style.overflow = ""

    this.dispatch("closed", { detail: { modal: this.modalTarget } })
  }

  backdropClick(event) {
    if (this.backdropValue && event.target === this.modalTarget) {
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
```

### Utilisation du contrôleur Modal
```erb
<!-- Vue avec modal -->
<div data-controller="modal"
     data-modal-backdrop-value="true"
     data-modal-keyboard-value="true"
     class="modal"
     data-modal-target="modal"
     tabindex="-1">

  <div class="modal-dialog" data-action="click->modal#backdropClick">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Confirmation</h5>
        <button type="button"
                class="btn-close"
                data-action="click->modal#close"></button>
      </div>

      <div class="modal-body">
        <p>Êtes-vous sûr de vouloir supprimer cet article ?</p>
      </div>

      <div class="modal-footer">
        <button type="button"
                class="btn btn-secondary"
                data-action="click->modal#close">Annuler</button>
        <%= link_to "Confirmer", article_path(@article),
                    method: :delete,
                    class: "btn btn-danger",
                    data: { turbo_method: :delete } %>
      </div>
    </div>
  </div>
</div>

<!-- Bouton pour ouvrir -->
<button type="button"
        class="btn btn-danger"
        data-action="click->modal#open">
  Supprimer
</button>
```

### Contrôleur pour formulaire dynamique
```javascript
// app/javascript/controllers/form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output", "field", "submit", "error"]
  static values = {
    url: String,
    method: String
  }

  connect() {
    this.validate()
  }

  validate() {
    const form = this.element
    const isValid = form.checkValidity()

    this.submitTarget.disabled = !isValid

    // Validation personnalisée
    this.fieldTargets.forEach(field => {
      this.validateField(field)
    })
  }

  validateField(field) {
    const errorElement = field.parentElement.querySelector('.error-message')

    if (field.validity.valid) {
      field.classList.remove('is-invalid')
      if (errorElement) errorElement.remove()
    } else {
      field.classList.add('is-invalid')
      if (!errorElement) {
        const error = document.createElement('div')
        error.className = 'error-message text-danger'
        error.textContent = field.validationMessage
        field.parentElement.appendChild(error)
      }
    }
  }

  async submit(event) {
    event.preventDefault()

    this.submitTarget.disabled = true
    this.submitTarget.textContent = "Envoi en cours..."

    try {
      const formData = new FormData(this.element)
      const response = await fetch(this.urlValue, {
        method: this.methodValue || 'POST',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })

      if (response.ok) {
        this.dispatch("success", { detail: { response } })
      } else {
        throw new Error('Erreur réseau')
      }
    } catch (error) {
      this.dispatch("error", { detail: { error } })
    } finally {
      this.submitTarget.disabled = false
      this.submitTarget.textContent = "Envoyer"
    }
  }

  // Action déclenchée par les changements de champs
  fieldChanged(event) {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.validate()
    }, 300)
  }
}
```

### Contrôleur pour autocomplétion
```javascript
// app/javascript/controllers/autocomplete_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "hiddenField"]
  static values = {
    url: String,
    minLength: { type: Number, default: 2 }
  }

  connect() {
    this.resultsTarget.hidden = true
    this.timeout = null
  }

  async search() {
    const query = this.inputTarget.value.trim()

    if (query.length < this.minLengthValue) {
      this.hideResults()
      return
    }

    clearTimeout(this.timeout)
    this.timeout = setTimeout(async () => {
      try {
        const url = new URL(this.urlValue)
        url.searchParams.set('q', query)

        const response = await fetch(url, {
          headers: {
            'Accept': 'application/json'
          }
        })

        const data = await response.json()
        this.displayResults(data)
      } catch (error) {
        console.error('Erreur autocomplete:', error)
      }
    }, 300)
  }

  displayResults(items) {
    this.resultsTarget.innerHTML = ''

    if (items.length === 0) {
      this.hideResults()
      return
    }

    items.forEach(item => {
      const element = document.createElement('div')
      element.className = 'autocomplete-item'
      element.textContent = item.name
      element.dataset.value = item.id
      element.addEventListener('click', () => this.selectItem(item))

      this.resultsTarget.appendChild(element)
    })

    this.resultsTarget.hidden = false
  }

  selectItem(item) {
    this.inputTarget.value = item.name
    this.hiddenFieldTarget.value = item.id
    this.hideResults()

    this.dispatch("selected", { detail: { item } })
  }

  hideResults() {
    this.resultsTarget.hidden = true
  }

  // Gestion du clavier
  keydown(event) {
    const items = this.resultsTarget.querySelectorAll('.autocomplete-item')

    switch(event.key) {
      case 'ArrowDown':
        event.preventDefault()
        this.highlightNext(items)
        break
      case 'ArrowUp':
        event.preventDefault()
        this.highlightPrevious(items)
        break
      case 'Enter':
        event.preventDefault()
        const highlighted = this.resultsTarget.querySelector('.highlighted')
        if (highlighted) {
          highlighted.click()
        }
        break
      case 'Escape':
        this.hideResults()
        break
    }
  }

  highlightNext(items) {
    const current = this.resultsTarget.querySelector('.highlighted')
    const currentIndex = current ? Array.from(items).indexOf(current) : -1
    const nextIndex = (currentIndex + 1) % items.length

    if (current) current.classList.remove('highlighted')
    items[nextIndex].classList.add('highlighted')
  }

  highlightPrevious(items) {
    const current = this.resultsTarget.querySelector('.highlighted')
    const currentIndex = current ? Array.from(items).indexOf(current) : items.length
    const prevIndex = (currentIndex - 1 + items.length) % items.length

    if (current) current.classList.remove('highlighted')
    items[prevIndex].classList.add('highlighted')
  }
}
```

### Utilisation de l'autocomplétion
```erb
<!-- Formulaire avec autocomplete -->
<%= form_with model: @article do |form| %>
  <div class="form-group"
       data-controller="autocomplete"
       data-autocomplete-url-value="<%= search_users_path %>"
       data-autocomplete-min-length-value="2">

    <%= form.label :author, "Auteur" %>
    <input type="text"
           class="form-control"
           data-autocomplete-target="input"
           data-action="input->autocomplete#search keydown->autocomplete#keydown"
           placeholder="Rechercher un auteur...">

    <%= form.hidden_field :user_id, data: { autocomplete_target: "hiddenField" } %>

    <div class="autocomplete-results"
         data-autocomplete-target="results"
         hidden></div>
  </div>
<% end %>
```

### Contrôleur pour drag & drop
```javascript
// app/javascript/controllers/sortable_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.element.addEventListener('dragstart', this.dragStart.bind(this))
    this.element.addEventListener('dragover', this.dragOver.bind(this))
    this.element.addEventListener('drop', this.drop.bind(this))
  }

  dragStart(event) {
    if (event.target.draggable) {
      event.dataTransfer.setData('text/plain', event.target.dataset.id)
      event.target.classList.add('dragging')
    }
  }

  dragOver(event) {
    event.preventDefault()
  }

  drop(event) {
    event.preventDefault()

    const draggedId = event.dataTransfer.getData('text/plain')
    const droppedOn = event.target.closest('[draggable="true"]')

    if (droppedOn && draggedId !== droppedOn.dataset.id) {
      this.reorder(draggedId, droppedOn.dataset.id)
    }

    document.querySelector('.dragging')?.classList.remove('dragging')
  }

  async reorder(draggedId, targetId) {
    try {
      const response = await fetch(this.urlValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          dragged_id: draggedId,
          target_id: targetId
        })
      })

      if (!response.ok) {
        throw new Error('Erreur lors du réordonnement')
      }
    } catch (error) {
      console.error('Erreur:', error)
      // Restaurer l'ordre original en cas d'erreur
    }
  }
}
```

Cette approche Hotwire vous permet de créer des interfaces modernes et interactives avec un minimum de JavaScript ! ⚡