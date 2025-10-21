# Exercice : Maîtriser le changement de statut de ScopeListMembership

## Objectif pédagogique

Comprendre comment le statut d'un `ScopeListMembership` évolue en fonction des bookings (sessions) associés à une relation coach-coachee, en utilisant l'analogie d'une **to-do list**.

---

## Analogie : La To-Do List

Imaginez que vous avez une **to-do list de projets** :

```
To-Do List : "Apprendre Ruby on Rails"
├── Tâche 1 : Installer Ruby ✓
├── Tâche 2 : Faire le tutoriel Rails ✓
├── Tâche 3 : Créer mon premier projet
└── Tâche 4 : Déployer sur Heroku
```

### Les statuts de votre to-do list

- **`not_started`** : Vous n'avez encore rien fait (aucune tâche)
- **`started`** : Vous avez commencé (au moins une tâche a été créée à un moment donné)
- **`in_progress`** : Vous êtes en train de travailler (il y a des tâches en cours ou terminées)
- **`completed`** : Tout est fini (toutes les tâches sont terminées)

---

## Correspondance avec Simundia

| To-Do List | Simundia |
|------------|----------|
| **To-Do List** | `ScopeListMembership` (le parcours de coaching) |
| **Tâche** | `Booking` (une session coach-coachee) |
| **Statut de la liste** | `status` du `ScopeListMembership` |
| **Supprimer une tâche** | Annuler un booking (passer son statut à `unplanned`) |

---

## Le code à comprendre (dans `delete_booking.rb`)

```ruby
relationship = booking.relationship                 # La relation coach-coachee
sml = relationship.scope_list_membership           # Le parcours (la to-do list)
bookings = relationship.bookings                   # Les tâches restantes
sml.started! if bookings.empty?                    # Si plus de tâches → revenir à "started"
```

---

## Exercice pratique : Scénarios à résoudre

### Scénario 1 : Supprimer la dernière tâche

**Situation initiale :**
```
Parcours de Marie : "Leadership Coaching" (status: in_progress)
├── Session 1 : 15 mars à 10h ✓ (terminée)
├── Session 2 : 22 mars à 14h ✓ (terminée)
└── Session 3 : 29 mars à 10h (planifiée)
```

**Action :** Marie annule la Session 3 (la dernière planifiée).

**Questions :**

1. Après l'annulation, combien de bookings reste-t-il dans `relationship.bookings` ?
   - [ ] 3 bookings
   - [ ] 2 bookings
   - [ ] 0 booking

2. La condition `bookings.empty?` est-elle vraie ?
   - [ ] Oui
   - [ ] Non

3. Quel sera le nouveau statut du `ScopeListMembership` ?
   - [ ] `not_started`
   - [ ] `started`
   - [ ] `in_progress`
   - [ ] `completed`

4. **Pourquoi ce statut ?** (Écrivez votre réponse)

---

### Scénario 2 : Supprimer une tâche parmi plusieurs

**Situation initiale :**
```
Parcours de Paul : "Reconversion Professionnelle" (status: in_progress)
├── Session 1 : 10 avril à 9h ✓ (terminée)
├── Session 2 : 17 avril à 9h (planifiée)
├── Session 3 : 24 avril à 14h (planifiée)
└── Session 4 : 1er mai à 10h (planifiée)
```

**Action :** Paul annule la Session 2.

**Questions :**

1. Après l'annulation, combien de bookings reste-t-il dans `relationship.bookings` ?
   - [ ] 4 bookings
   - [ ] 3 bookings
   - [ ] 2 bookings
   - [ ] 0 booking

2. La condition `bookings.empty?` est-elle vraie ?
   - [ ] Oui
   - [ ] Non

3. Le statut du `ScopeListMembership` va-t-il changer ?
   - [ ] Oui, il passe à `started`
   - [ ] Non, il reste `in_progress`

4. **Pourquoi ?** (Écrivez votre réponse)

---

### Scénario 3 : Supprimer toutes les tâches une par une

**Situation initiale :**
```
Parcours de Sophie : "Gestion du Stress" (status: in_progress)
├── Session 1 : 5 mai à 11h (planifiée)
└── Session 2 : 12 mai à 11h (planifiée)
```

**Actions :**
1. Sophie annule la Session 1
2. Puis Sophie annule la Session 2

**Questions :**

**Après l'annulation de la Session 1 :**

1. Combien de bookings restent ?
   - [ ] 2
   - [ ] 1
   - [ ] 0

2. Le statut change-t-il ?
   - [ ] Oui → `started`
   - [ ] Non → reste `in_progress`

**Après l'annulation de la Session 2 :**

3. Combien de bookings restent ?
   - [ ] 1
   - [ ] 0

4. Le statut change-t-il maintenant ?
   - [ ] Oui → `started`
   - [ ] Non → reste `in_progress`

5. **Conclusion :** À quel moment exact le statut passe-t-il à `started` ?

---

## Point technique important à comprendre

### Que contient `relationship.bookings` ?

Cette ligne récupère les bookings de la relation, **mais pas tous** :

```ruby
bookings = relationship.bookings
```

**Question cruciale :** Est-ce que `relationship.bookings` inclut les bookings avec le statut `unplanned` ?

👉 **Réponse :** Probablement **non**. Il y a sûrement un **scope** dans le modèle `Relationship` qui filtre les bookings :

```ruby
# Dans app/models/relationship.rb (hypothèse)
has_many :bookings, -> { where.not(status: :unplanned) }
```

**Exercice :** Allez vérifier dans le fichier `app/models/relationship.rb` comment est définie l'association `bookings`.

---

## Tests à écrire (pour valider votre compréhension)

Écrivez des tests RSpec pour les 3 scénarios ci-dessus. Voici un exemple pour le Scénario 1 :

```ruby
context 'when deleting the last remaining booking' do
  let(:booking) { relationship.bookings.first }

  before do
    # S'assurer qu'il n'y a qu'un seul booking actif
    relationship.bookings.where.not(id: booking.id).destroy_all
  end

  it 'changes scope_list_membership status to started' do
    expect { use_case }.to change { relationship.scope_list_membership.reload.status }
      .to('started')
  end

  it 'has no remaining bookings after deletion' do
    use_case
    expect(relationship.reload.bookings).to be_empty
  end
end
```

---

## Schéma récapitulatif

```
┌─────────────────────────────────────────────────┐
│         ScopeListMembership (Parcours)          │
│                                                 │
│  Statuts possibles :                            │
│  • not_started : Jamais commencé                │
│  • started : Commencé mais plus de sessions     │ ← NOTRE CAS
│  • in_progress : Sessions actives               │
│  • completed : Parcours terminé                 │
└─────────────────────────────────────────────────┘
                      ↓
         ┌────────────────────────┐
         │    Relationship        │
         │  (Coach ↔ Coachee)     │
         └────────────────────────┘
                      ↓
         ┌────────────────────────┐
         │   Bookings (Sessions)  │
         │  • planned             │
         │  • finished            │
         │  • unplanned ← annulé  │
         └────────────────────────┘
```

### Logique du changement de statut :

```
SI (plus aucun booking actif)
ALORS
  Remettre le statut à "started"
  (= le parcours a démarré historiquement, mais il n'y a plus de sessions)
SINON
  Ne rien changer
FIN SI
```

---

## Questions de réflexion finale

1. **Pourquoi ne pas remettre le statut à `not_started` au lieu de `started` ?**

2. **Que se passerait-il si on oubliait de vérifier `bookings.empty?` et qu'on appelait toujours `sml.started!` ?**

3. **Dans quel autre cas de figure pourrait-on vouloir changer le statut du `ScopeListMembership` ?**

---

## Pour aller plus loin

Une fois que vous maîtrisez ce concept, cherchez dans le code d'autres endroits où le statut du `ScopeListMembership` est modifié :

```bash
# Rechercher dans tout le projet
grep -r "scope_list_membership.*!" app/
```

Vous découvrirez d'autres transitions de statut et comprendrez le cycle de vie complet d'un parcours de coaching !

---

**Bon courage ! 🚀**
