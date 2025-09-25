# Structures Conditionnelles en Ruby

# 1. If/elsif/else basique
age = 20

if age >= 18
  puts "Vous êtes majeur"
elsif age >= 16
  puts "Vous êtes presque majeur"
else
  puts "Vous êtes mineur"
end

# 2. Unless (contraire de if)
temps = "ensoleillé"

unless temps == "pluvieux"
  puts "On peut sortir!"
end

# 3. Opérateur ternaire
statut = age >= 18 ? "majeur" : "mineur"
puts "Statut: #{statut}"

# 4. Case/when (équivalent du switch)
note = "B"

resultat = case note
           when "A"
             "Excellent"
           when "B"
             "Très bien"
           when "C"
             "Bien"
           when "D"
             "Passable"
           else
             "À améliorer"
           end

puts "Résultat: #{resultat}"

# 5. Case avec ranges
score = 85

appreciation = case score
               when 90..100
                 "Exceptionnel"
               when 80..89
                 "Très bien"
               when 70..79
                 "Bien"
               when 60..69
                 "Passable"
               else
                 "Insuffisant"
               end

puts "Score #{score}: #{appreciation}"

# 6. Conditions avec méthodes de String
nom = "alice"

if nom.empty?
  puts "Le nom est vide"
elsif nom.include?("a")
  puts "Le nom contient la lettre 'a'"
end

# 7. Conditions multiples
temperature = 22
humidite = 45

if temperature > 20 && humidite < 60
  puts "Conditions idéales!"
end

if temperature < 0 || temperature > 35
  puts "Conditions extrêmes"
end

# 8. Modifier conditionnellement (syntax Ruby idiomatique)
message = "Il fait beau"
message += " aujourd'hui" if Time.now.wday == 3  # Si c'est mercredi

puts message

# Exercices
puts "\n=== EXERCICES ==="

puts "1. Écrivez un programme qui détermine la saison selon le mois"
mois = 7
# Votre code ici (1-3: hiver, 4-6: printemps, 7-9: été, 10-12: automne)
mois = 7
if mois >=1 && mois <= 3
  puts 'winter'
elsif mois >= 4 && mois <=6
  puts 'autumn'
elsif mois >= 7 && mois <=9
  puts " summer"
else
  puts 'spring'
end

puts "2. Créez un système de notation d'un examen (0-100 points)"
points = 78
# Votre code ici (A: 90-100, B: 80-89, C: 70-79, D: 60-69, F: 0-59)

puts "3. Vérifiez si un nombre est pair ou impair"
nombre = 17
# Votre code ici
if nombre % 2 === 0
  puts 'It is a pair number'
else
  puts 'It is impair number'
end

puts "4. Déterminez la catégorie d'âge d'une personne"
age_personne = 35
# Votre code ici (enfant: 0-12, ado: 13-17, adulte: 18-64, senior: 65+)