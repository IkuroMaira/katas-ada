# Exercices Ruby - Niveau 1 (Débutant)

puts "=== EXERCICES RUBY NIVEAU 1 ==="

# EXERCICE 1: Variables et affichage
puts "\n--- Exercice 1: Présentez-vous ---"
puts "Créez des variables pour votre nom, âge, ville et affichez une phrase complète"

# À compléter:
# mon_nom =
# mon_age =
# ma_ville =
# puts "Je m'appelle #{mon_nom}, j'ai #{mon_age} ans et j'habite à #{ma_ville}"

# EXERCICE 2: Calculs simples
puts "\n--- Exercice 2: Calculatrice basique ---"
puts "Créez deux nombres et affichez leur somme, différence, produit et division"

# À compléter:
# nombre1 =
# nombre2 =

# EXERCICE 3: Tableaux
puts "\n--- Exercice 3: Gestion d'une liste de courses ---"
puts "Créez un tableau de 5 articles, ajoutez un 6ème, et affichez le nombre total"

# À compléter:
# courses =

# EXERCICE 4: Hash/Dictionnaire
puts "\n--- Exercice 4: Carnet d'adresses ---"
puts "Créez un hash avec 3 contacts (nom => téléphone) et affichez-les"

# À compléter:
# contacts =

# EXERCICE 5: Conditions
puts "\n--- Exercice 5: Contrôle d'accès ---"
puts "Créez un programme qui vérifie si une personne peut entrer (18+ ans)"

# À compléter:
age_visiteur = 16  # Testez avec différentes valeurs

# EXERCICE 6: Boucles
puts "\n--- Exercice 6: Table de multiplication ---"
puts "Affichez la table de 7 (7x1=7, 7x2=14, etc. jusqu'à 7x10)"

# À compléter:

# EXERCICE 7: Manipulation de chaînes
puts "\n--- Exercice 7: Analyseur de texte ---"
texte = "Ruby est un langage de programmation formidable"
puts "Texte: #{texte}"
puts "Comptez les mots, les caractères, et vérifiez si 'Ruby' est présent"

# À compléter:

# EXERCICE 8: Conditions multiples
puts "\n--- Exercice 8: Système de notes ---"
puts "Convertissez une note numérique (0-100) en lettre (A, B, C, D, F)"

note_numerique = 85  # Testez avec différentes valeurs
# À compléter (A: 90-100, B: 80-89, C: 70-79, D: 60-69, F: 0-59):

# EXERCICE 9: Itération sur un tableau
puts "\n--- Exercice 9: Prix avec TVA ---"
prix_ht = [100, 200, 50, 300, 150]
tva = 0.20
puts "Prix HT: #{prix_ht}"
puts "Calculez et affichez les prix TTC (HT + 20% de TVA)"

# À compléter:

# EXERCICE 10: Méthodes de tableaux
puts "\n--- Exercice 10: Statistiques ---"
nombres = [12, 45, 67, 23, 89, 34, 56, 78, 90, 21]
puts "Nombres: #{nombres}"
puts "Trouvez: le maximum, le minimum, la moyenne, et les nombres pairs"

# À compléter:

# BONUS: Jeu simple
puts "\n--- BONUS: Devine le nombre ---"
puts "Créez un jeu où l'ordinateur 'pense' à un nombre entre 1 et 10"
puts "L'utilisateur a 3 essais pour deviner"

# À compléter (utilisez rand(1..10) pour générer un nombre aléatoire):


puts "\n=== FIN DES EXERCICES NIVEAU 1 ==="
puts "Vérifiez vos réponses en exécutant: ruby exercices-ruby-niveau-1.rb"