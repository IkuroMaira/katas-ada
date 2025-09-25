# Méthodes et Blocs en Ruby

puts "=== MÉTHODES EN RUBY ==="

# 1. Définition de méthodes simples
def dire_bonjour
  puts "Bonjour tout le monde!"
end

def saluer(nom)
  puts "Salut #{nom}!"
end

def additionner(a, b)
  a + b  # Retour implicite (dernière ligne évaluée)
end

# Appel des méthodes
dire_bonjour
saluer("Alice")
resultat = additionner(5, 3)
puts "5 + 3 = #{resultat}"

# 2. Méthodes avec valeurs par défaut
def presenter(nom, age = 25, ville = "Paris")
  puts "Je m'appelle #{nom}, j'ai #{age} ans et j'habite à #{ville}"
end

puts "\n=== Paramètres par défaut ==="
presenter("Bob")
presenter("Claire", 30)
presenter("David", 28, "Lyon")

# 3. Méthodes avec nombre variable d'arguments (*args)
def calculer_moyenne(*nombres)
  return 0 if nombres.empty?
  somme = nombres.sum
  somme.to_f / nombres.length
end

puts "\n=== Arguments variables ==="
puts "Moyenne de 1,2,3: #{calculer_moyenne(1, 2, 3)}"
puts "Moyenne de 10,20,30,40: #{calculer_moyenne(10, 20, 30, 40)}"

# 4. Méthodes avec arguments nommés (keywords)
def creer_utilisateur(nom:, email:, age: 18, actif: true)
  {
    nom: nom,
    email: email,
    age: age,
    actif: actif
  }
end

puts "\n=== Arguments nommés ==="
user1 = creer_utilisateur(nom: "Alice", email: "alice@example.com")
user2 = creer_utilisateur(nom: "Bob", email: "bob@example.com", age: 30, actif: false)
puts "User1: #{user1}"
puts "User2: #{user2}"

# 5. Méthodes qui retournent plusieurs valeurs
def diviser_avec_reste(dividende, diviseur)
  quotient = dividende / diviseur
  reste = dividende % diviseur
  [quotient, reste]  # Retourne un tableau
end

puts "\n=== Retours multiples ==="
q, r = diviser_avec_reste(17, 5)
puts "17 ÷ 5 = #{q} reste #{r}"

# 6. Méthodes avec blocs
def trois_fois
  yield
  yield
  yield
end

def avec_message
  puts "Avant le bloc"
  yield
  puts "Après le bloc"
end

puts "\n=== Méthodes avec blocs ==="
trois_fois { puts "Hello!" }

avec_message do
  puts "Je suis dans le bloc"
end

# 7. Méthodes avec paramètres pour les blocs
def repeter(n)
  n.times do |i|
    yield(i + 1)
  end
end

puts "\n=== Blocs avec paramètres ==="
repeter(3) { |numero| puts "Répétition #{numero}" }

# 8. Block_given? pour vérifier la présence d'un bloc
def optionnel_avec_bloc(message)
  puts message
  if block_given?
    yield
  else
    puts "Aucun bloc fourni"
  end
end

puts "\n=== Bloc optionnel ==="
optionnel_avec_bloc("Test 1") { puts "Bloc exécuté!" }
optionnel_avec_bloc("Test 2")

# 9. Méthodes avec &block explicite
def executer_bloc(&block)
  puts "Préparation..."
  block.call if block
  puts "Terminé!"
end

executer_bloc { puts "Code du bloc" }

# 10. Procs et Lambdas
puts "\n=== Procs et Lambdas ==="

# Proc
mon_proc = Proc.new { |x| x * 2 }
puts "Proc: #{mon_proc.call(5)}"

# Lambda
mon_lambda = lambda { |x| x * 3 }
# Ou syntaxe moderne:
mon_lambda_moderne = ->(x) { x * 3 }

puts "Lambda: #{mon_lambda.call(5)}"
puts "Lambda moderne: #{mon_lambda_moderne.call(5)}"

# 11. Méthodes utilitaires courantes
def est_pair?(nombre)
  nombre.even?
end

def formater_nom(prenom, nom)
  "#{prenom.capitalize} #{nom.upcase}"
end

def calculer_tva(prix_ht, taux = 0.20)
  prix_ht * (1 + taux)
end

puts "\n=== Méthodes utilitaires ==="
puts "6 est pair? #{est_pair?(6)}"
puts "7 est pair? #{est_pair?(7)}"
puts "Nom formaté: #{formater_nom('alice', 'dupont')}"
puts "Prix TTC: #{calculer_tva(100)}€"

# 12. Méthodes de classe vs méthodes d'instance (aperçu)
class MaClasse
  def self.methode_de_classe
    "Je suis une méthode de classe"
  end

  def methode_instance
    "Je suis une méthode d'instance"
  end
end

puts "\n=== Méthodes de classe vs instance ==="
puts MaClasse.methode_de_classe
puts MaClasse.new.methode_instance

# Exercices
puts "\n=== EXERCICES ==="

puts "1. Créez une méthode qui calcule l'aire d'un rectangle"
# def aire_rectangle(longueur, largeur)
#   # Votre code ici
# end

puts "2. Créez une méthode qui trouve le plus grand de 3 nombres"
# def plus_grand(a, b, c)
#   # Votre code ici
# end

puts "3. Créez une méthode qui compte les voyelles dans un texte"
# def compter_voyelles(texte)
#   # Votre code ici
# end

puts "4. Créez une méthode avec un bloc pour filtrer un tableau"
# def filtrer_nombres(tableau)
#   # Utiliser yield pour filtrer
# end

puts "5. Créez une méthode qui génère un mot de passe aléatoire"
# def generer_mot_de_passe(longueur = 8)
#   # Votre code ici
# end