# Modules et Mixins en Ruby

puts "=== MODULES ET MIXINS EN RUBY ==="

# 1. Module simple avec méthodes
module Salutations
  def dire_bonjour
    puts "Bonjour de #{self.class}!"
  end

  def dire_au_revoir
    puts "Au revoir de #{self.class}!"
  end
end

# 2. Utiliser un module avec include
class Personne
  include Salutations

  attr_accessor :nom

  def initialize(nom)
    @nom = nom
  end
end

puts "\n=== Include dans une classe ==="
alice = Personne.new("Alice")
alice.dire_bonjour
alice.dire_au_revoir

# 3. Module avec constantes et méthodes de module
module Mathematiques
  PI = 3.14159
  E = 2.71828

  def self.aire_cercle(rayon)
    PI * rayon ** 2
  end

  def self.factorielle(n)
    return 1 if n <= 1
    n * factorielle(n - 1)
  end

  # Méthode pour les instances qui incluent le module
  def calculer_perimetre_cercle(rayon)
    2 * PI * rayon
  end
end

puts "\n=== Méthodes et constantes de module ==="
puts "Aire du cercle (r=5): #{Mathematiques.aire_cercle(5)}"
puts "5! = #{Mathematiques.factorielle(5)}"
puts "PI = #{Mathematiques::PI}"

# 4. Extend vs Include
module Fonctionnalites
  def methode_partagee
    "Je peux être utilisée partout!"
  end
end

class AvecInclude
  include Fonctionnalites
end

class AvecExtend
  extend Fonctionnalites
end

puts "\n=== Include vs Extend ==="
# Include: ajoute les méthodes aux instances
obj_include = AvecInclude.new
puts "Avec include: #{obj_include.methode_partagee}"

# Extend: ajoute les méthodes à la classe elle-même
puts "Avec extend: #{AvecExtend.methode_partagee}"

# 5. Module namespacing
module Geometrie
  module Plane
    class Rectangle
      attr_accessor :longueur, :largeur

      def initialize(longueur, largeur)
        @longueur = longueur
        @largeur = largeur
      end

      def aire
        @longueur * @largeur
      end
    end

    class Cercle
      attr_accessor :rayon

      def initialize(rayon)
        @rayon = rayon
      end

      def aire
        Math::PI * @rayon ** 2
      end
    end
  end

  module Espace3D
    class Cube
      attr_accessor :cote

      def initialize(cote)
        @cote = cote
      end

      def volume
        @cote ** 3
      end
    end
  end
end

puts "\n=== Namespacing avec modules ==="
rectangle = Geometrie::Plane::Rectangle.new(5, 3)
cercle = Geometrie::Plane::Cercle.new(4)
cube = Geometrie::Espace3D::Cube.new(3)

puts "Aires rectangle: #{rectangle.aire}"
puts "Aires cercle: #{cercle.aire.round(2)}"
puts "Volume cube: #{cube.volume}"

# 6. Mixins complexes avec plusieurs modules
module Loggable
  def log(message)
    puts "[#{Time.now}] #{self.class}: #{message}"
  end
end

module Validatable
  def valide?
    # Méthode à redéfinir dans les classes
    true
  end

  def valider!
    unless valide?
      raise "Objet non valide: #{self}"
    end
  end
end

module Persistable
  def sauvegarder
    log("Sauvegarde en cours...") if respond_to?(:log)
    valider! if respond_to?(:valider!)
    puts "#{self.class} sauvegardé avec succès"
  end
end

class Utilisateur
  include Loggable
  include Validatable
  include Persistable

  attr_accessor :nom, :email

  def initialize(nom, email)
    @nom = nom
    @email = email
  end

  def valide?
    !@nom.empty? && @email.include?("@")
  end

  def to_s
    "Utilisateur: #{@nom} (#{@email})"
  end
end

puts "\n=== Mixins complexes ==="
user = Utilisateur.new("Bob", "bob@example.com")
user.log("Utilisateur créé")
user.sauvegarder

# 7. Module avec méthodes de callback
module Callbacks
  def self.included(base)
    puts "Module Callbacks inclus dans #{base}"
    base.extend(ClassMethods)
  end

  module ClassMethods
    def before_save(method_name)
      define_method :save do
        send(method_name)
        puts "Sauvegarde effectuée"
      end
    end
  end
end

class Document
  include Callbacks

  attr_accessor :titre, :contenu

  def initialize(titre, contenu)
    @titre = titre
    @contenu = contenu
  end

  before_save :valider_document

  private

  def valider_document
    puts "Validation du document: #{@titre}"
  end
end

puts "\n=== Callbacks avec modules ==="
doc = Document.new("Mon document", "Contenu du document")
doc.save

# 8. Enumerable - un module Ruby très puissant
class ListeTaches
  include Enumerable

  def initialize
    @taches = []
  end

  def ajouter(tache)
    @taches << tache
  end

  # Méthode requise par Enumerable
  def each
    @taches.each { |tache| yield(tache) }
  end
end

puts "\n=== Module Enumerable ==="
liste = ListeTaches.new
liste.ajouter("Faire les courses")
liste.ajouter("Étudier Ruby")
liste.ajouter("Faire du sport")

# Grace à Enumerable, on a accès à plein de méthodes:
puts "Toutes les tâches:"
liste.each { |tache| puts "- #{tache}" }

puts "\nTâches contenant 'Ruby':"
liste.select { |tache| tache.include?("Ruby") }.each { |t| puts "- #{t}" }

puts "Nombre de tâches: #{liste.count}"

# 9. Module avec alias et méthodes privées
module StringUtils
  def self.palindrome?(chaine)
    chaine_nettoyee = nettoyer_chaine(chaine)
    chaine_nettoyee == chaine_nettoyee.reverse
  end

  def self.compter_mots(texte)
    texte.split.length
  end

  alias_method :nb_mots, :compter_mots  # Alias

  private_class_method def self.nettoyer_chaine(chaine)
    chaine.downcase.gsub(/[^a-z0-9]/, '')
  end
end

puts "\n=== Module utilitaire ==="
puts "Est palindrome? #{StringUtils.palindrome?('A man a plan a canal Panama')}"
puts "Nombre de mots: #{StringUtils.compter_mots('Bonjour tout le monde Ruby')}"

# 10. Module pour des constantes partagées
module Configuration
  VERSION = "1.0.0"
  DEBUG = true
  BASE_URL = "https://api.example.com"

  COULEURS = {
    rouge: "#FF0000",
    vert: "#00FF00",
    bleu: "#0000FF"
  }.freeze

  def self.afficher_config
    puts "Version: #{VERSION}"
    puts "Debug: #{DEBUG}"
    puts "URL de base: #{BASE_URL}"
  end
end

puts "\n=== Configuration partagée ==="
Configuration.afficher_config
puts "Couleur rouge: #{Configuration::COULEURS[:rouge]}"

# Exercices
puts "\n=== EXERCICES ==="

puts "1. Créez un module Comparable personnalisé pour une classe Produit"
# module ComparableProduit
#   # Votre code ici
# end

puts "2. Créez un module Debug qui ajoute des méthodes de débogage"
# module Debug
#   # inspect_object, print_vars, etc.
# end

puts "3. Utilisez un module pour créer un namespace 'Jeux' avec plusieurs classes"
# module Jeux
#   class CartesPoker
#   end
#   class Echecs
#   end
# end

puts "4. Créez un module Statistiques à inclure dans un tableau"
# module Statistiques
#   def moyenne
#   def mediane
#   def ecart_type
# end

puts "5. Implémentez un module Observer pattern"