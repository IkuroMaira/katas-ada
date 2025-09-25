# Héritage et Polymorphisme en Ruby

puts "=== HÉRITAGE ET POLYMORPHISME EN RUBY ==="

# 1. Héritage simple
class Vehicule
  attr_accessor :marque, :modele, :annee

  def initialize(marque, modele, annee)
    @marque = marque
    @modele = modele
    @annee = annee
    @moteur_demarre = false
  end

  def demarrer
    unless @moteur_demarre
      @moteur_demarre = true
      puts "#{@marque} #{@modele} démarré"
    else
      puts "Le moteur est déjà démarré"
    end
  end

  def arreter
    if @moteur_demarre
      @moteur_demarre = false
      puts "#{@marque} #{@modele} arrêté"
    else
      puts "Le moteur est déjà arrêté"
    end
  end

  def info
    puts "#{@marque} #{@modele} (#{@annee})"
  end

  def klaxonner
    puts "Beep beep!"
  end
end

class Voiture < Vehicule
  attr_accessor :nb_portes, :type_carburant

  def initialize(marque, modele, annee, nb_portes, type_carburant = "essence")
    super(marque, modele, annee)  # Appelle le constructeur parent
    @nb_portes = nb_portes
    @type_carburant = type_carburant
  end

  def info  # Redéfinition (override)
    super  # Appelle la méthode parent
    puts "Voiture #{@nb_portes} portes, carburant: #{@type_carburant}"
  end

  def klaxonner  # Redéfinition
    puts "Pouet pouet! (voiture)"
  end

  def ouvrir_coffre
    puts "Coffre ouvert"
  end
end

class Moto < Vehicule
  attr_accessor :cylindree

  def initialize(marque, modele, annee, cylindree)
    super(marque, modele, annee)
    @cylindree = cylindree
  end

  def info
    super
    puts "Moto #{@cylindree}cc"
  end

  def klaxonner
    puts "Tut tut! (moto)"
  end

  def faire_wheelie
    puts "Wheelie! 🏍️"
  end
end

puts "\n=== Héritage simple ==="
voiture = Voiture.new("Toyota", "Corolla", 2020, 4, "hybride")
moto = Moto.new("Yamaha", "R1", 2021, 1000)

voiture.info
voiture.demarrer
voiture.klaxonner
voiture.ouvrir_coffre

puts "\n"
moto.info
moto.demarrer
moto.klaxonner
moto.faire_wheelie

# 2. Polymorphisme - même interface, comportements différents
puts "\n=== Polymorphisme ==="
vehicules = [
  Voiture.new("BMW", "X3", 2019, 4),
  Moto.new("Honda", "CBR", 2020, 600),
  Voiture.new("Tesla", "Model 3", 2022, 4, "électrique")
]

# Tous les véhicules répondent aux mêmes méthodes de base
vehicules.each do |vehicule|
  vehicule.demarrer
  vehicule.klaxonner
  puts "---"
end

# 3. Classes abstraites simulées avec méthodes à implémenter
class Forme
  def initialize(nom)
    @nom = nom
  end

  def aire
    raise NotImplementedError, "Méthode aire doit être implémentée"
  end

  def perimetre
    raise NotImplementedError, "Méthode perimetre doit être implémentée"
  end

  def info
    puts "Forme: #{@nom}"
    puts "Aire: #{aire}"
    puts "Périmètre: #{perimetre}"
  end
end

class Rectangle < Forme
  def initialize(longueur, largeur)
    super("Rectangle")
    @longueur = longueur
    @largeur = largeur
  end

  def aire
    @longueur * @largeur
  end

  def perimetre
    2 * (@longueur + @largeur)
  end
end

class Cercle < Forme
  def initialize(rayon)
    super("Cercle")
    @rayon = rayon
  end

  def aire
    Math::PI * @rayon ** 2
  end

  def perimetre
    2 * Math::PI * @rayon
  end
end

puts "\n=== Classes 'abstraites' ==="
formes = [
  Rectangle.new(5, 3),
  Cercle.new(4)
]

formes.each do |forme|
  forme.info
  puts "---"
end

# 4. Héritage multiple simulé avec modules
module Volant
  def voler
    puts "Je vole dans les airs!"
  end

  def atterrir
    puts "J'atterris"
  end
end

module Nageur
  def nager
    puts "Je nage dans l'eau"
  end

  def plonger
    puts "Je plonge"
  end
end

class Animal
  attr_accessor :nom, :espece

  def initialize(nom, espece)
    @nom = nom
    @espece = espece
  end

  def dormir
    puts "#{@nom} dort"
  end

  def manger
    puts "#{@nom} mange"
  end
end

class Canard < Animal
  include Volant
  include Nageur

  def initialize(nom)
    super(nom, "canard")
  end

  def crier
    puts "#{@nom} fait coin coin!"
  end
end

class Poisson < Animal
  include Nageur

  def initialize(nom)
    super(nom, "poisson")
  end

  def respirer_sous_eau
    puts "#{@nom} respire sous l'eau"
  end
end

class Oiseau < Animal
  include Volant

  def initialize(nom)
    super(nom, "oiseau")
  end

  def construire_nid
    puts "#{@nom} construit un nid"
  end
end

puts "\n=== Héritage multiple simulé ==="
donald = Canard.new("Donald")
nemo = Poisson.new("Nemo")
tweety = Oiseau.new("Tweety")

donald.crier
donald.voler
donald.nager

nemo.nager
nemo.respirer_sous_eau

tweety.voler
tweety.construire_nid

# 5. Chaîne d'héritage et super
class EtreVivant
  def initialize(nom)
    @nom = nom
    puts "EtreVivant créé: #{@nom}"
  end

  def vivre
    puts "#{@nom} vit"
  end
end

class Mammifere < EtreVivant
  def initialize(nom, poils = true)
    super(nom)
    @poils = poils
    puts "Mammifère créé avec poils: #{@poils}"
  end

  def vivre
    super
    puts "#{@nom} respire avec des poumons"
  end

  def allaiter
    puts "#{@nom} allaite ses petits"
  end
end

class Chien < Mammifere
  def initialize(nom, race)
    super(nom)
    @race = race
    puts "Chien de race #{@race} créé"
  end

  def vivre
    super
    puts "#{@nom} aboie et remue la queue"
  end

  def aboyer
    puts "#{@nom} aboie: Woof!"
  end
end

puts "\n=== Chaîne d'héritage ==="
rex = Chien.new("Rex", "Labrador")
puts "\nComportement:"
rex.vivre
rex.aboyer
rex.allaiter

# 6. Introspection de classe et d'héritage
puts "\n=== Introspection ==="
puts "Classe de rex: #{rex.class}"
puts "Superclasse: #{rex.class.superclass}"
puts "Chaîne d'héritage: #{rex.class.ancestors}"
puts "rex est-il un Mammifere? #{rex.is_a?(Mammifere)}"
puts "rex est-il un EtreVivant? #{rex.is_a?(EtreVivant)}"
puts "Chien est-il une sous-classe de Animal? #{Chien < Animal}"

# 7. Méthodes de classe héritées
class Compteur
  @@total = 0

  def initialize
    @@total += 1
  end

  def self.total
    @@total
  end

  def self.remettre_a_zero
    @@total = 0
  end
end

class CompteurSpecial < Compteur
  def self.doubler_compteur
    @@total *= 2
  end
end

puts "\n=== Méthodes de classe héritées ==="
puts "Total initial: #{Compteur.total}"

c1 = Compteur.new
c2 = Compteur.new
cs1 = CompteurSpecial.new

puts "Après création: #{Compteur.total}"
CompteurSpecial.doubler_compteur
puts "Après doublement: #{CompteurSpecial.total}"

# 8. Pattern Template Method
class AlgorithmeTriAbstrait
  def trier(tableau)
    puts "Début du tri"
    tableau_trie = implementation_tri(tableau.dup)
    puts "Tri terminé"
    tableau_tri
  end

  protected

  def implementation_tri(tableau)
    raise NotImplementedError, "À implémenter dans les sous-classes"
  end
end

class TriRapide < AlgorithmeTriAbstrait
  protected

  def implementation_tri(tableau)
    puts "Utilisation du tri rapide"
    tableau.sort  # Simplification pour l'exemple
  end
end

class TriBulle < AlgorithmeTriAbstrait
  protected

  def implementation_tri(tableau)
    puts "Utilisation du tri à bulles"
    # Implémentation simplifiée
    n = tableau.length
    loop do
      echange = false
      (n-1).times do |i|
        if tableau[i] > tableau[i+1]
          tableau[i], tableau[i+1] = tableau[i+1], tableau[i]
          echange = true
        end
      end
      break unless echange
    end
    tableau
  end
end

puts "\n=== Pattern Template Method ==="
nombres = [64, 34, 25, 12, 22, 11, 90]
puts "Tableau original: #{nombres}"

tri_rapide = TriRapide.new
resultat1 = tri_rapide.trier(nombres)
puts "Résultat: #{resultat1}"

tri_bulle = TriBulle.new
resultat2 = tri_bulle.trier(nombres)
puts "Résultat: #{resultat2}"

# Exercices
puts "\n=== EXERCICES ==="

puts "1. Créez une hiérarchie Employé -> Développeur, Manager"
# class Employe
#   # nom, salaire, calculer_bonus (à redéfinir)
# end

puts "2. Implémentez le polymorphisme avec des instruments de musique"
# class Instrument -> Piano, Guitare, Batterie
# Méthode jouer() différente pour chaque

puts "3. Créez une classe abstraite Media -> Livre, Film, Musique"
# Méthodes abstraites: duree, genre

puts "4. Utilisez l'héritage pour un système de fichiers"
# Fichier -> FichierTexte, FichierImage, FichierVideo

puts "5. Implémentez le pattern Strategy avec l'héritage"
# StrategieCalcul -> CalculSimple, CalculAvance