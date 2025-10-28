# Projet Pratique : To-Do List pour comprendre ScopeListMembership

## Objectif

Créer un projet Rails simplifié qui reproduit **exactement** la logique métier de `ScopeListMembership` et `DeleteBooking` dans Simundia, mais avec une analogie simple : une **application de gestion de to-do lists**.

---

## Vue d'ensemble du projet

### Correspondance avec Simundia

| Simundia | Projet To-Do List |
|----------|-------------------|
| `ScopeListMembership` | `TodoList` (une liste de tâches) |
| `Relationship` | `Project` (un projet qui contient une liste) |
| `Booking` | `Task` (une tâche dans la liste) |
| `DeleteBooking` service | `DeleteTask` service |
| Statut `unplanned` | Statut `cancelled` |
| Statut `started` | Statut `started` |
| Statut `in_progress` | Statut `in_progress` |

---

## Étape 1 : Créer le projet Rails

```bash
# Créer un nouveau projet Rails
rails new todo_list_exercise --database=postgresql

cd todo_list_exercise

# Créer la base de données
rails db:create
```

---

## Étape 2 : Créer les modèles

### 2.1 Modèle `TodoList`

```bash
rails generate model TodoList name:string status:integer
```

**Fichier : `app/models/todo_list.rb`**

```ruby
# frozen_string_literal: true

class TodoList < ApplicationRecord
  # Statuts possibles
  enum status: {
    not_started: 0,   # Jamais commencé
    started: 1,       # Commencé, mais plus de tâches actives
    in_progress: 2,   # Des tâches sont actives
    completed: 3      # Tout est terminé
  }

  has_one :project, dependent: :destroy

  validates :name, presence: true
end
```

### 2.2 Modèle `Project`

```bash
rails generate model Project name:string todo_list:references
```

**Fichier : `app/models/project.rb`**

```ruby
# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :todo_list
  has_many :tasks, dependent: :destroy

  # Scope : ne retourne que les tâches actives (pas cancelled)
  has_many :active_tasks, -> { where.not(status: :cancelled) }, class_name: 'Task'

  validates :name, presence: true

  # Méthode similaire à reorder_course_step_relationships
  def reorder_tasks
    active_tasks.order(:position).each_with_index do |task, index|
      task.update(position: index + 1)
    end
  end
end
```

### 2.3 Modèle `Task`

```bash
rails generate model Task title:string status:integer project:references position:integer due_date:datetime
```

**Fichier : `app/models/task.rb`**

```ruby
# frozen_string_literal: true

class Task < ApplicationRecord
  # Statuts possibles
  enum status: {
    planned: 0,      # Tâche planifiée
    in_progress: 1,  # En cours
    completed: 2,    # Terminée
    cancelled: 3     # Annulée (équivalent de unplanned)
  }

  belongs_to :project

  validates :title, presence: true
  validates :position, presence: true, numericality: { greater_than: 0 }

  # Scope : tâches actives (pas cancelled)
  scope :active, -> { where.not(status: :cancelled) }
end
```

### 2.4 Migration : Ajouter les index

Modifier les migrations pour ajouter les index nécessaires :

**Fichier : `db/migrate/XXXXXX_create_tasks.rb`**

```ruby
class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.integer :status, default: 0, null: false
      t.references :project, null: false, foreign_key: true # Crée automatiquement un index sur project_id
      t.integer :position, default: 1, null: false
      t.datetime :due_date

      t.timestamps
    end

    add_index :tasks, [:project_id, :status] # Permet d'aller directement sur les colonnes concernées et évite de lire toutes les colonnes
    add_index :tasks, [:project_id, :position] # Index composite (plusieurs colonnes): pour des requêtes qui filtrent sur plusieurs colonnes
  end
end
```

```bash
# Lancer les migrations
rails db:migrate
```

---

## Étape 3 : Créer le service `DeleteTask`

**Fichier : `app/services/delete_task.rb`**

```ruby
# frozen_string_literal: true

# Service pour annuler une tâche
# La tâche n'est pas vraiment supprimée. Au lieu de cela :
# - change le statut à `cancelled`
# - met à jour le TodoList parent
#
# LOGIQUE CLÉE :
# Si après l'annulation il ne reste plus aucune tâche active,
# le statut du TodoList repasse à `started`
class DeleteTask
  attr_reader :task, :reason

  def initialize(task, reason: nil)
    @task = task
    @reason = reason
  end

  def perform
    ActiveRecord::Base.transaction do
      # Marquer la tâche comme cancelled
      task.status = :cancelled
      task.save!

      # Réorganiser les tâches restantes
      task.project.reorder_tasks

      # LOGIQUE PRINCIPALE : Gérer le statut du TodoList
      project = task.project
      todo_list = project.todo_list
      active_tasks = project.active_tasks

      # Si plus aucune tâche active, remettre le statut à "started"
      if active_tasks.empty?
        todo_list.started!
      end
    end

    { success: true, message: "Task cancelled successfully" }
  end
end
```

---

## Étape 4 : Créer les tests RSpec

### 4.1 Installation de RSpec

```bash
# Ajouter RSpec au Gemfile
bundle add rspec-rails --group "development, test"

# Installer RSpec
rails generate rspec:install

# Ajouter FactoryBot
bundle add factory_bot_rails --group "development, test"
```

### 4.2 Créer les factories

**Fichier : `spec/factories/todo_lists.rb`**

```ruby
FactoryBot.define do
  factory :todo_list do
    sequence(:name) { |n| "Todo List #{n}" }
    status { :in_progress }
  end
end
```

**Fichier : `spec/factories/projects.rb`**

```ruby
FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    association :todo_list
  end
end
```

**Fichier : `spec/factories/tasks.rb`**

```ruby
FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Task #{n}" }
    status { :planned }
    position { 1 }
    association :project

    trait :completed do
      status { :completed }
    end

    trait :cancelled do
      status { :cancelled }
    end
  end
end
```

### 4.3 Créer les tests du service

**Fichier : `spec/services/delete_task_spec.rb`**

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteTask do
  describe '#perform' do
    let(:todo_list) { create(:todo_list, status: :in_progress) }
    let(:project) { create(:project, todo_list: todo_list) }

    subject(:delete_task) { described_class.new(task, reason: 'Not needed anymore').perform }

    describe 'basic task cancellation' do
      let(:task) { create(:task, project: project, status: :planned) }

      it 'changes task status to cancelled' do
        expect { delete_task }.to change { task.reload.status }.from('planned').to('cancelled')
      end

      it 'does not destroy the task from database' do
        expect { delete_task }.not_to change(Task, :count)
      end
    end

    describe 'todo_list status management' do
      context 'when cancelling the last remaining active task' do
        let!(:task) { create(:task, project: project, status: :planned, position: 1) }

        before do
          # S'assurer qu'il n'y a qu'une seule tâche active
          project.active_tasks.where.not(id: task.id).destroy_all
        end

        it 'changes todo_list status to started' do
          expect { delete_task }
            .to change { todo_list.reload.status }
            .to('started')
        end

        it 'has no remaining active tasks after cancellation' do
          delete_task
          expect(project.reload.active_tasks).to be_empty
        end
      end

      context 'when there are other active tasks remaining' do
        let!(:task1) { create(:task, project: project, status: :planned, position: 1) }
        let!(:task2) { create(:task, project: project, status: :planned, position: 2) }
        let(:task) { task1 }

        it 'does not change todo_list status' do
          initial_status = todo_list.status

          expect { delete_task }
            .not_to change { todo_list.reload.status }
            .from(initial_status)
        end

        it 'still has active tasks after cancellation' do
          delete_task
          expect(project.reload.active_tasks).not_to be_empty
          expect(project.active_tasks.count).to eq(1)
        end
      end

      context 'when cancelling multiple tasks sequentially' do
        let!(:task1) { create(:task, project: project, status: :planned, position: 1) }
        let!(:task2) { create(:task, project: project, status: :planned, position: 2) }
        let!(:task3) { create(:task, project: project, status: :planned, position: 3) }

        before do
          # Annuler toutes les autres tâches pour partir d'une base propre
          Task.where(project: project).where.not(id: [task1.id, task2.id, task3.id]).update_all(status: :cancelled)
        end

        it 'only changes status to started when last task is cancelled' do
          # Vérifier qu'on a bien 3 tâches au départ
          expect(project.active_tasks.count).to eq(3)

          # Annuler la première tâche - le statut ne doit pas changer
          described_class.new(project.active_tasks.first, reason: 'Test').perform
          expect(todo_list.reload.status).to eq('in_progress')
          expect(project.reload.active_tasks.count).to eq(2)

          # Annuler la deuxième tâche - le statut ne doit toujours pas changer
          described_class.new(project.reload.active_tasks.first, reason: 'Test').perform
          expect(todo_list.reload.status).to eq('in_progress')
          expect(project.reload.active_tasks.count).to eq(1)

          # Annuler la dernière tâche - maintenant le statut doit passer à 'started'
          described_class.new(project.reload.active_tasks.first, reason: 'Test').perform
          expect(todo_list.reload.status).to eq('started')
          expect(project.reload.active_tasks).to be_empty
        end
      end
    end

    describe 'task reordering' do
      let!(:task1) { create(:task, project: project, status: :planned, position: 1) }
      let!(:task2) { create(:task, project: project, status: :planned, position: 2) }
      let!(:task3) { create(:task, project: project, status: :planned, position: 3) }
      let(:task) { task2 }

      it 'reorders remaining tasks after cancellation' do
        delete_task

        expect(project.reload.active_tasks.order(:position).pluck(:position)).to eq([1, 2])
      end
    end
  end
end
```

---

## Étape 5 : Lancer les tests

```bash
bundle exec rspec spec/services/delete_task_spec.rb
```

**Résultat attendu :** Tous les tests doivent passer ! ✅

---

## Étape 6 : Exercices pratiques

### Exercice 1 : Comprendre le scope `active_tasks`

1. Ouvrez la console Rails :
   ```bash
   rails console
   ```

2. Créez un projet avec des tâches :
   ```ruby
   todo_list = TodoList.create!(name: "Ma liste", status: :in_progress)
   project = Project.create!(name: "Mon projet", todo_list: todo_list)

   task1 = Task.create!(title: "Tâche 1", project: project, status: :planned, position: 1)
   task2 = Task.create!(title: "Tâche 2", project: project, status: :planned, position: 2)
   task3 = Task.create!(title: "Tâche 3", project: project, status: :cancelled, position: 3)
   ```

3. Testez le scope :
   ```ruby
   # Toutes les tâches
   project.tasks.count
   # => 3

   # Seulement les tâches actives
   project.active_tasks.count
   # => 2 (task3 est cancelled)
   ```

**Question :** Pourquoi `active_tasks` ne retourne que 2 tâches ?

**Réponse :** Parce que le scope `active_tasks` filtre avec `where.not(status: :cancelled)`, excluant donc task3.

---

### Exercice 2 : Tester la logique de changement de statut

Continuez dans la console Rails :

```ruby
# Annuler la première tâche
DeleteTask.new(task1, reason: "Test").perform

# Vérifier le statut
todo_list.reload.status
# => "in_progress" (car il reste task2)

project.active_tasks.count
# => 1

# Annuler la dernière tâche active
DeleteTask.new(task2, reason: "Test").perform

# Vérifier le statut
todo_list.reload.status
# => "started" (plus aucune tâche active)

project.active_tasks.count
# => 0
```

**Question :** Pourquoi le statut ne passe à `started` qu'après avoir annulé task2 ?

**Réponse :** Parce que la condition `if active_tasks.empty?` n'est vraie qu'après l'annulation de la dernière tâche active.

---

### Exercice 3 : Ajouter une fonctionnalité

Ajoutez une méthode `restore` dans le service pour **réactiver** une tâche annulée :

**Fichier : `app/services/restore_task.rb`**

```ruby
class RestoreTask
  attr_reader :task

  def initialize(task)
    @task = task
  end

  def perform
    ActiveRecord::Base.transaction do
      task.status = :planned
      task.save!

      project = task.project
      todo_list = project.todo_list

      # Si la liste était "started" et qu'on rajoute une tâche,
      # elle doit repasser à "in_progress"
      if todo_list.started?
        todo_list.in_progress!
      end
    end

    { success: true, message: "Task restored successfully" }
  end
end
```

**Créez le test :**

```ruby
RSpec.describe RestoreTask do
  let(:todo_list) { create(:todo_list, status: :started) }
  let(:project) { create(:project, todo_list: todo_list) }
  let(:task) { create(:task, :cancelled, project: project) }

  subject(:restore_task) { described_class.new(task).perform }

  it 'changes task status back to planned' do
    expect { restore_task }.to change { task.reload.status }.from('cancelled').to('planned')
  end

  it 'changes todo_list status to in_progress' do
    expect { restore_task }.to change { todo_list.reload.status }.from('started').to('in_progress')
  end
end
```

---

## Étape 7 : Créer une interface web simple (optionnel)

### 7.1 Générer le contrôleur

```bash
rails generate controller Tasks index
```

### 7.2 Routes

**Fichier : `config/routes.rb`**

```ruby
Rails.application.routes.draw do
  resources :projects do
    resources :tasks do
      member do
        patch :cancel
        patch :restore
      end
    end
  end

  root "projects#index"
end
```

### 7.3 Contrôleur

**Fichier : `app/controllers/tasks_controller.rb`**

```ruby
class TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [:cancel, :restore]

  def index
    @tasks = @project.active_tasks
    @todo_list = @project.todo_list
  end

  def cancel
    DeleteTask.new(@task, reason: params[:reason]).perform
    redirect_to project_tasks_path(@project), notice: "Task cancelled"
  end

  def restore
    RestoreTask.new(@task).perform
    redirect_to project_tasks_path(@project), notice: "Task restored"
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  end
end
```

### 7.4 Vue simple

**Fichier : `app/views/tasks/index.html.erb`**

```erb
<h1><%= @project.name %></h1>
<p>Todo List Status: <strong><%= @project.todo_list.status %></strong></p>

<h2>Active Tasks (<%= @tasks.count %>)</h2>

<% if @tasks.empty? %>
  <p>No active tasks. The todo list is in "<%= @project.todo_list.status %>" state.</p>
<% else %>
  <ul>
    <% @tasks.each do |task| %>
      <li>
        <%= task.title %> - <%= task.status %>
        <%= button_to "Cancel", cancel_project_task_path(@project, task), method: :patch %>
      </li>
    <% end %>
  </ul>
<% end %>
```

---

## Résumé : Ce que vous avez appris

### ✅ Concepts maîtrisés

1. **Scopes ActiveRecord** : Comprendre comment `active_tasks` filtre les enregistrements
2. **Logique conditionnelle** : Le changement de statut basé sur `active_tasks.empty?`
3. **Transactions** : Garantir l'intégrité des données avec `ActiveRecord::Base.transaction`
4. **Tests RSpec** : Tester différents scénarios métier
5. **Service Objects** : Encapsuler la logique métier complexe

### 🔗 Lien avec Simundia

Vous comprenez maintenant **exactement** comment fonctionne la logique dans `app/services/delete_booking.rb` :

```ruby
# Dans Simundia (delete_booking.rb)
relationship = booking.relationship
sml = relationship.scope_list_membership
bookings = relationship.bookings
sml.started! if bookings.empty?
```

**Est équivalent à :**

```ruby
# Dans votre projet (delete_task.rb)
project = task.project
todo_list = project.todo_list
active_tasks = project.active_tasks
todo_list.started! if active_tasks.empty?
```

---

## Pour aller plus loin

### Défis supplémentaires

1. **Ajouter la gestion du statut `completed`**
   - Quand toutes les tâches sont `completed`, le TodoList passe à `completed`

2. **Ajouter un historique des annulations**
   - Créer un modèle `TaskCancellation` (similaire à `BookingReschedulingRequest`)

3. **Ajouter des notifications**
   - Envoyer un email quand le TodoList change de statut

4. **Ajouter des métriques**
   - Calculer le taux de complétion du projet

---

**Bon courage avec votre apprentissage ! 🚀**
