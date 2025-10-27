# Exercice pratique : Maîtriser les requêtes ActiveRecord de base et leur encapsulation

## Contexte de l'exercice

Nous allons utiliser votre exercice existant sur les `ScopeListMembership` et `Booking` pour **pratiquer concrètement** les requêtes ActiveRecord et leur encapsulation dans les modèles.

---

## Partie 1 : Comprendre les requêtes de base présentes dans votre code

### Analyse du code existant

Dans le fichier `delete_booking.rb`, vous avez cette ligne :

```ruby
bookings = relationship.bookings
```

**Question 1 :** Cette ligne utilise quelle méthode ActiveRecord ?
- [ ] `where`
- [ ] `find`
- [ ] Association (méthode définie par `has_many`)
- [ ] `all`

<details>
<summary>💡 Voir la réponse</summary>

**Réponse :** Association (méthode définie par `has_many`)

C'est une méthode générée automatiquement par Rails quand vous définissez `has_many :bookings` dans le modèle `Relationship`.
</details>

---

### Exercice 1.1 : Écrire des requêtes de base

Ouvrez votre console Rails (`rails console`) et essayez ces commandes :

```ruby
# 1. Trouver tous les bookings d'une relation spécifique
relationship = Relationship.first
bookings = relationship.bookings

# 2. Filtrer les bookings planifiés uniquement
planned_bookings = relationship.bookings.where(status: "planned")

# 3. Trier les bookings par date
sorted_bookings = relationship.bookings.order(start_time: :asc)

# 4. Combiner plusieurs conditions
active_bookings = relationship.bookings
  .where.not(status: "unplanned")
  .order(start_time: :asc)

# 5. Compter les bookings
count = relationship.bookings.count

# 6. Vérifier si la liste est vide
is_empty = relationship.bookings.empty?
```

**Mission :** Testez chaque commande et notez le résultat. Comprenez ce que chacune fait.

---

### Exercice 1.2 : Requêtes sur ScopeListMembership

Maintenant, explorons les requêtes sur `ScopeListMembership` :

```ruby
# 1. Trouver tous les parcours "in_progress"
in_progress_slm = ScopeListMembership.where(status: "in_progress")

# 2. Trouver les parcours démarrés (started) ou en cours (in_progress)
active_slm = ScopeListMembership.where(status: ["started", "in_progress"])

# 3. Compter les parcours terminés
completed_count = ScopeListMembership.where(status: "completed").count

# 4. Trouver les parcours d'un coachee spécifique
coachee = Coachee.first
coachee_slm = ScopeListMembership.where(coachee_id: coachee.id)
# OU (si l'association existe)
coachee_slm = coachee.scope_list_memberships
```

**À faire :**
1. Testez ces commandes dans votre console
2. Écrivez 3 nouvelles requêtes de votre choix

---

## Partie 2 : Encapsuler les requêtes dans les modèles

### Problème actuel

Regardez cette ligne dans `delete_booking.rb` :

```ruby
bookings = relationship.bookings
```

**Question :** Cette ligne récupère-t-elle TOUS les bookings ou seulement certains ?

<details>
<summary>💡 Indice</summary>

Allez vérifier dans `app/models/relationship.rb` comment l'association `has_many :bookings` est définie. Y a-t-il un lambda avec des conditions ?
</details>

---

### Exercice 2.1 : Créer des scopes dans le modèle Booking

Ouvrez (ou créez) le fichier `app/models/booking.rb` et ajoutez ces scopes :

```ruby
class Booking < ApplicationRecord
  # Relations existantes
  belongs_to :relationship
  
  # Énumérations
  enum status: {
    planned: "planned",
    finished: "finished",
    unplanned: "unplanned"
  }
  
  # === VOS SCOPES À CRÉER ===
  
  # Scope 1 : Bookings actifs (pas annulés)
  scope :active, -> { where.not(status: :unplanned) }
  
  # Scope 2 : Bookings planifiés uniquement
  scope :planned_only, -> { where(status: :planned) }
  
  # Scope 3 : Bookings terminés
  scope :finished_only, -> { where(status: :finished) }
  
  # Scope 4 : Bookings futurs (après aujourd'hui)
  scope :upcoming, -> { where("start_time > ?", Time.current) }
  
  # Scope 5 : Bookings passés
  scope :past, -> { where("start_time < ?", Time.current) }
  
  # Scope 6 : Bookings triés par date
  scope :chronological, -> { order(start_time: :asc) }
end
```

**Mission :** 
1. Copiez ces scopes dans votre modèle `Booking`
2. Testez-les dans la console :

```ruby
# Tester les scopes
Booking.active
Booking.planned_only
Booking.upcoming.chronological

# Combiner des scopes
relationship.bookings.active.upcoming.chronological
```

---

### Exercice 2.2 : Méthodes de classe vs Scopes

Maintenant, créons des méthodes de classe pour des requêtes plus complexes :

```ruby
class Booking < ApplicationRecord
  # ... scopes existants ...
  
  # Méthode de classe 1 : Bookings d'une période
  def self.in_date_range(start_date, end_date)
    where(start_time: start_date..end_date)
  end
  
  # Méthode de classe 2 : Bookings par coach
  def self.for_coach(coach_id)
    joins(:relationship).where(relationships: { coach_id: coach_id })
  end
  
  # Méthode de classe 3 : Statistiques
  def self.completion_rate
    total = count
    return 0 if total.zero?
    
    finished = finished_only.count
    (finished.to_f / total * 100).round(2)
  end
end
```

**Testez dans la console :**

```ruby
# Bookings entre deux dates
Booking.in_date_range(1.month.ago, Date.today)

# Bookings d'un coach spécifique
Booking.for_coach(Coach.first.id)

# Taux de complétion
Booking.completion_rate
```

---

### Exercice 2.3 : Encapsuler dans ScopeListMembership

Ouvrez `app/models/scope_list_membership.rb` et ajoutez :

```ruby
class ScopeListMembership < ApplicationRecord
  belongs_to :relationship
  
  enum status: {
    not_started: "not_started",
    started: "started",
    in_progress: "in_progress",
    completed: "completed"
  }
  
  # === SCOPES ===
  
  scope :active, -> { where(status: [:started, :in_progress]) }
  scope :not_completed, -> { where.not(status: :completed) }
  
  # === MÉTHODES DE CLASSE ===
  
  def self.with_active_bookings
    joins(relationship: :bookings)
      .where(bookings: { status: ["planned", "finished"] })
      .distinct
  end
  
  # === MÉTHODES D'INSTANCE ===
  
  # Vérifier si le parcours a des sessions actives
  def has_active_bookings?
    relationship.bookings.active.exists?
  end
  
  # Mettre à jour le statut intelligemment
  def update_status_based_on_bookings!
    if relationship.bookings.active.empty?
      started! if in_progress?
    end
  end
end
```

---

## Partie 3 : Refactoriser votre code existant

### Mission finale : Améliorer `delete_booking.rb`

**Code actuel :**
```ruby
relationship = booking.relationship
sml = relationship.scope_list_membership
bookings = relationship.bookings
sml.started! if bookings.empty?
```

**Code refactorisé avec vos nouvelles méthodes :**

```ruby
relationship = booking.relationship
sml = relationship.scope_list_membership

# Version 1 : Utiliser le scope
sml.started! if relationship.bookings.active.empty?

# Version 2 : Utiliser une méthode d'instance
sml.update_status_based_on_bookings!

# Version 3 : Encore plus propre
sml.started! unless sml.has_active_bookings?
```

---

## Exercices de validation

### Quiz de compréhension

**Question 1 :** Quelle est la différence entre ces deux lignes ?
```ruby
# A
Booking.where(status: "planned")

# B
Booking.planned_only
```

<details>
<summary>Voir la réponse</summary>

**Aucune différence fonctionnelle** si le scope `planned_only` est défini comme `scope :planned_only, -> { where(status: :planned) }`.

**Avantages du scope :**
- Plus lisible
- Réutilisable
- Facilite les tests
- Centralise la logique
</details>

---

**Question 2 :** Pourquoi utilise-t-on `->` (lambda) dans les scopes ?

```ruby
# Correct
scope :upcoming, -> { where("start_time > ?", Time.current) }

# Incorrect
scope :upcoming, where("start_time > ?", Time.current)
```

<details>
<summary>Voir la réponse</summary>

Sans lambda, `Time.current` serait évalué **au moment du chargement de la classe** (au démarrage de l'application), pas au moment de l'exécution de la requête.

Avec le lambda, `Time.current` est évalué **à chaque appel du scope**, ce qui donne toujours la date/heure actuelle.
</details>

---

### Mini-projet : Créer un scope complexe

Créez un scope qui retourne les bookings "à risque" :
- Planifiés (status: planned)
- Dans moins de 48h
- Dont le coachee n'a pas encore confirmé (hypothèse : champ `confirmed_by_coachee`)

```ruby
class Booking < ApplicationRecord
  scope :at_risk, -> {
    # VOTRE CODE ICI
    # Indices :
    # - where(status: :planned)
    # - where("start_time BETWEEN ? AND ?", Time.current, 48.hours.from_now)
    # - where(confirmed_by_coachee: false)
  }
end
```

<details>
<summary>Voir la solution</summary>

```ruby
scope :at_risk, -> {
  where(status: :planned)
    .where("start_time BETWEEN ? AND ?", Time.current, 48.hours.from_now)
    .where(confirmed_by_coachee: false)
}

# OU en chaînant des scopes existants
scope :at_risk, -> {
  planned_only
    .where("start_time BETWEEN ? AND ?", Time.current, 48.hours.from_now)
    .where(confirmed_by_coachee: false)
}
```
</details>

---

## Checklist de maîtrise

Cochez quand vous êtes à l'aise avec :

### Requêtes de base
- [ ] `where` avec un hash
- [ ] `where` avec une condition SQL
- [ ] `where.not`
- [ ] `order`
- [ ] `limit`
- [ ] `count`, `empty?`, `exists?`
- [ ] Chaîner plusieurs méthodes

### Encapsulation
- [ ] Créer un scope simple
- [ ] Créer un scope avec lambda
- [ ] Créer une méthode de classe
- [ ] Chaîner des scopes
- [ ] Comprendre quand utiliser scope vs méthode de classe

### Mise en pratique
- [ ] J'ai testé tous les exemples dans ma console
- [ ] J'ai créé au moins 3 scopes personnalisés
- [ ] J'ai refactorisé une partie de mon code existant
- [ ] Je comprends l'exercice sur `ScopeListMembership`

---

## Pour aller plus loin

Une fois que vous maîtrisez ces bases, vous serez prêt pour :
- Les requêtes avec `joins` (requêtes sur les associations)
- Le eager loading (`includes`, `preload`)
- Les agrégations (`group`, `having`, calculs)
- Les requêtes SQL personnalisées

**Prochaine étape :** Revenez à votre exercice initial et répondez aux questions en utilisant vos nouvelles connaissances ! 🚀
