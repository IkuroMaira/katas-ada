# Exercice 1 :
# Crée un programme qui demande à l'utilisateur son nom, son âge, et calcule en quelle année il/elle aura 100 ans.

def giveAge(name, age)
  puts "Pouvez-vous donner votre nom ?"
  puts "Pouvez vous donner votre âge?"
  puts "Bonjour #{name} !"
  puts "Vous avez #{age} ans"

  today = 2025
  remainingYears = 100 - age
  yearof100years = today + remainingYears

  puts "Et vous aurez 100 ans en #{yearof100years}."
end

giveAge("Gwen", 31)
giveAge("Ludo", 30)
giveAge("Laurianne", 25)

# Faire une version avec un fichier HTML qui demande et récupère les réponses