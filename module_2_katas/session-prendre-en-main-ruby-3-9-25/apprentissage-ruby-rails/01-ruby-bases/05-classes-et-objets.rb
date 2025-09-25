# Classes et Objets en Ruby

puts "=== CLASSES ET OBJETS EN RUBY ==="

# 1. Définition d'une classe simple
class Personne
  # Constructeur
  def initialize(nom, age)
    @nom = nom    # Variable d'instance
    @age = age
  end

  # Méthodes d'instance
  def se_presenter
    puts "Bonjour, je m'appelle #{@nom} et j'ai #{@age} ans"
  end

  def avoir_anniversaire
    @age += 1
    puts "Joyeux anniversaire! J'ai maintenant #{@age} ans"
  end

  # Getters (accesseurs)
  def nom
    @nom
  end

  def age
    @age
  end

  # Setters (mutateurs)
  def nom=(nouveau_nom)
    @nom = nouveau_nom
  end

  def age=(nouvel_age)
    if nouvel_age >= 0
      @age = nouvel_age
    else
      puts "L'âge ne peut pas être négatif!"
    end
  end
end

# Utilisation de la classe
puts "\n=== Utilisation basique ==="
alice = Personne.new("Alice", 25)
bob = Personne.new("Bob", 30)

alice.se_presenter
bob.se_presenter
alice.avoir_anniversaire

# 2. Accesseurs automatiques avec attr_*
class Produit
  attr_reader :nom, :prix      # Lecture seule
  attr_writer :description     # Écriture seule
  attr_accessor :stock         # Lecture et écriture

  def initialize(nom, prix)
    @nom = nom
    @prix = prix
    @stock = 0
    @description = ""
  end

  def afficher_info
    puts "#{@nom}: #{@prix}€ (stock: #{@stock})"
    puts "Description: #{@description}" unless @description.empty?
  end
end

puts "\n=== Accesseurs automatiques ==="
produit = Produit.new("Livre Ruby", 25.99)
produit.stock = 50
produit.description = "Un excellent livre sur Ruby"
produit.afficher_info

# 3. Méthodes de classe et constantes
class Calculatrice
  PI = 3.14159  # Constante de classe

  # Méthode de classe
  def self.additionner(a, b)
    a + b
  end

  def self.aire_cercle(rayon)
    PI * rayon * rayon
  end

  # Variable de classe
  @@nombre_calculs = 0

  def initialize
    @@nombre_calculs += 1
  end

  def self.nombre_calculs
    @@nombre_calculs
  end

  def calculer(operation, a, b)
    @@nombre_calculs += 1
    case operation
    when "+"
      a + b
    when "-"
      a - b
    when "*"
      a * b
    when "/"
      b != 0 ? a.to_f / b : "Division par zéro!"
    else
      "Opération inconnue"
    end
  end
end

puts "\n=== Méthodes de classe ==="
puts "5 + 3 = #{Calculatrice.additionner(5, 3)}"
puts "Aire d'un cercle (r=5): #{Calculatrice.aire_cercle(5)}"

calc1 = Calculatrice.new
calc2 = Calculatrice.new
puts "Nombre de calculatrices créées: #{Calculatrice.nombre_calculs}"
puts "10 / 3 = #{calc1.calculer('/', 10, 3)}"

# 4. Classe avec validation et méthodes privées
class CompteBancaire
  attr_reader :numero, :solde

  def initialize(numero, solde_initial = 0)
    @numero = numero
    @solde = solde_initial
  end

  def deposer(montant)
    if montant_valide?(montant)
      @solde += montant
      enregistrer_transaction("Dépôt", montant)
      puts "Dépôt de #{montant}€ effectué. Nouveau solde: #{@solde}€"
    end
  end

  def retirer(montant)
    if montant_valide?(montant) && solde_suffisant?(montant)
      @solde -= montant
      enregistrer_transaction("Retrait", montant)
      puts "Retrait de #{montant}€ effectué. Nouveau solde: #{@solde}€"
    end
  end

  def afficher_solde
    puts "Compte #{@numero}: #{@solde}€"
  end

  private  # Méthodes privées

  def montant_valide?(montant)
    if montant > 0
      true
    else
      puts "Le montant doit être positif!"
      false
    end
  end

  def solde_suffisant?(montant)
    if @solde >= montant
      true
    else
      puts "Solde insuffisant! Solde actuel: #{@solde}€"
      false
    end
  end

  def enregistrer_transaction(type, montant)
    puts "Transaction enregistrée: #{type} de #{montant}€"
  end
end

puts "\n=== Classe avec validation ==="
compte = CompteBancaire.new("12345", 100)
compte.afficher_solde
compte.deposer(50)
compte.retirer(30)
compte.retirer(200)  # Solde insuffisant

# 5. Héritage
class Animal
  attr_reader :nom, :espece

  def initialize(nom, espece)
    @nom = nom
    @espece = espece
  end

  def se_presenter
    puts "Je suis #{@nom}, un(e) #{@espece}"
  end

  def dormir
    puts "#{@nom} dort paisiblement"
  end
end

class Chien < Animal
  attr_accessor :race

  def initialize(nom, race)
    super(nom, "chien")  # Appelle le constructeur parent
    @race = race
  end

  def aboyer
    puts "#{@nom} aboie: Woof woof!"
  end

  def se_presenter  # Redéfinition de méthode
    super  # Appelle la méthode parent
    puts "Je suis un #{@race}"
  end
end

class Chat < Animal
  def initialize(nom, couleur)
    super(nom, "chat")
    @couleur = couleur
  end

  def miauler
    puts "#{@nom} miaule: Miaou miaou!"
  end

  def ronronner
    puts "#{@nom} ronronne contentement"
  end
end

puts "\n=== Héritage ==="
rex = Chien.new("Rex", "Labrador")
felix = Chat.new("Félix", "noir")

rex.se_presenter
rex.aboyer
rex.dormir

felix.se_presenter
felix.miauler
felix.ronronner

# 6. Méthodes utilitaires pour les objets
puts "\n=== Introspection d'objets ==="
puts "Classe de rex: #{rex.class}"
puts "rex est-il un Animal? #{rex.is_a?(Animal)}"
puts "rex est-il un Chien? #{rex.is_a?(Chien)}"
puts "rex répond à 'aboyer'? #{rex.respond_to?(:aboyer)}"

# 7. ToString personnalisé
class Livre
  attr_accessor :titre, :auteur, :pages

  def initialize(titre, auteur, pages)
    @titre = titre
    @auteur = auteur
    @pages = pages
  end

  def to_s
    "\"#{@titre}\" par #{@auteur} (#{@pages} pages)"
  end

  def inspect
    "#<Livre: #{@titre} - #{@auteur}>"
  end
end

puts "\n=== Méthodes d'affichage ==="
livre = Livre.new("1984", "George Orwell", 328)
puts livre  # Utilise to_s automatiquement
p livre     # Utilise inspect

# Exercices
puts "\n=== EXERCICES ==="

puts "1. Créez une classe Voiture avec marque, modèle, année"
# class Voiture
#   # Votre code ici
# end

puts "2. Ajoutez des méthodes démarrer, arreter, klaxonner"

puts "3. Créez une classe Étudiant qui hérite de Personne"
# class Etudiant < Personne
#   # Ajoutez école, niveau
# end

puts "4. Créez une classe Rectangle avec méthodes aire et périmètre"

puts "5. Créez une classe CompteurGlobal avec une variable de classe"