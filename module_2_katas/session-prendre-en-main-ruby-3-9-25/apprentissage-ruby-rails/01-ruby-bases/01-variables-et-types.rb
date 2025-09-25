# Variables et Types de Données en Ruby

# 1. Variables simples
nom = "Alice"
age = 25
taille = 1.65
est_majeur = true

puts "Nom: #{nom}"
puts "Age: #{age}"
puts "Taille: #{taille}m"
puts "Majeur: #{est_majeur}"

# 2. Types de données
puts "\n=== Types de données ==="
puts nom.class      # String
puts age.class      # Integer
puts taille.class   # Float
puts est_majeur.class # TrueClass

# 3. Chaînes de caractères
message = "Bonjour tout le monde!"
multiline = <<~TEXT
  Ceci est un texte
  sur plusieurs lignes
TEXT

puts "\n=== Chaînes ==="
puts message.upcase
puts message.length
puts multiline

# 4. Nombres
nombre_entier = 42
nombre_decimal = 3.14159
puts "\n=== Calculs ==="
puts "Addition: #{nombre_entier + 10}"
puts "Pi arrondi: #{nombre_decimal.round(2)}"

# 5. Tableaux
fruits = ["pomme", "banane", "orange"]
nombres = [1, 2, 3, 4, 5]

puts "\n=== Tableaux ==="
puts "Premier fruit: #{fruits[0]}"
puts "Dernier fruit: #{fruits[-1]}"
puts "Nombre de fruits: #{fruits.length}"

# 6. Hachages (Hash)
personne = {
  "nom" => "Bob",
  "age" => 30,
  "ville" => "Paris"
}

# Syntaxe moderne avec symboles
personne_moderne = {
  nom: "Claire",
  age: 28,
  ville: "Lyon"
}

puts "\n=== Hachages ==="
puts "Nom: #{personne['nom']}"
puts "Age moderne: #{personne_moderne[:age]}"

# 7. Symboles
statut = :actif
puts "\n=== Symboles ==="
puts "Statut: #{statut}"
puts "Type: #{statut.class}"

# Exercices
puts "\n=== EXERCICES ==="
puts "1. Créez une variable avec votre nom et affichez-la"
# 25/09/2025
nom = "Gwen"
puts nom

puts "2. Créez un tableau de vos 3 couleurs préférées"
# 25/09/2025
favorite_colors = ['bleu', 'rouge', 'vert']
puts favorite_colors

puts "3. Créez un hash avec vos informations personnelles"
# Votre code ici
identity_card = {
  name: nom,
  age: 31,
  color: favorite_colors
}
puts identity_card
