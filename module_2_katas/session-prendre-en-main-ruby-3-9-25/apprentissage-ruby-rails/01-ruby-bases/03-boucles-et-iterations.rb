# Boucles et Itérations en Ruby

puts "=== Boucles en Ruby ==="

# 1. Boucle while
puts "\n1. Boucle while:"
compteur = 1
while compteur <= 5
  puts "Compteur: #{compteur}"
  compteur += 1
end

# 2. Boucle until (contraire de while)
puts "\n2. Boucle until:"
nombre = 10
until nombre == 0
  puts "Décompte: #{nombre}"
  nombre -= 1
end

# 3. Boucle for avec range
puts "\n3. Boucle for avec range:"
for i in 1..3
  puts "Itération #{i}"
end

# 4. Times (façon Ruby idiomatique)
puts "\n4. Méthode times:"
3.times do |i|
  puts "Times itération #{i}"
end

# 5. Each avec tableaux
puts "\n5. Each avec tableaux:"
fruits = ["pomme", "banane", "cerise"]
fruits.each do |fruit|
  puts "J'aime les #{fruit}s"
end

# 6. Each avec hash
# Un hash en Ruby, c'est comme un objet JavaScript : une collection de paires clé-valeur.
puts "\n6. Each avec hash:"
ages = { "Alice" => 25, "Bob" => 30, "Claire" => 28 }
ages.each do |nom, age|
  puts "#{nom} a #{age} ans"
end

# 7. Each_with_index
puts "\n7. Each_with_index:"
couleurs = ["rouge", "vert", "bleu"]
couleurs.each_with_index do |couleur, index|
  puts "#{index + 1}. #{couleur}"
end

# 8. Select (filtrer)
puts "\n8. Select (filtrer):"
nombres = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
pairs = nombres.select { |n| n.even? }
puts "Nombres pairs: #{pairs}"

# 9. Map (transformer)
puts "\n9. Map (transformer):"
mots = ["hello", "world", "ruby"]
mots_majuscules = mots.map { |mot| mot.upcase }
puts "En majuscules: #{mots_majuscules}"

# 10. Reject (contraire de select)
puts "\n10. Reject:"
impairs = nombres.reject { |n| n.even? }
puts "Nombres impairs: #{impairs}"

# 11. Find (trouve le premier élément)
puts "\n11. Find:"
premier_grand = nombres.find { |n| n > 5 }
puts "Premier nombre > 5: #{premier_grand}"

# 12. Reduce (accumulation)
puts "\n12. Reduce:"
somme = nombres.reduce(0) { |total, n| total + n }
# Ou plus simple:
somme_simple = nombres.sum
puts "Somme: #{somme} (ou #{somme_simple})"

# 13. Range avec step
puts "\n13. Range avec step:"
(0..20).step(5) do |n|
  puts "Step: #{n}"
end

# 14. Loop avec break et next
puts "\n14. Loop avec break et next:"
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
numbers.each do |n|
  next if n.even?  # Passe au suivant si pair
  puts "Nombre impair: #{n}"
  break if n > 7   # Sort de la boucle si > 7
end

# 15. Upto et downto
puts "\n15. Upto et downto:"
1.upto(3) { |i| puts "Upto: #{i}" }
3.downto(1) { |i| puts "Downto: #{i}" }

# Exercices
puts "\n=== EXERCICES ==="

puts "\n1. Calculez la factorial de 5 (5! = 5*4*3*2*1)"
# Votre code ici

puts "\n2. Trouvez tous les nombres divisibles par 3 entre 1 et 30"
# Votre code ici

puts "\n3. Créez un tableau des carrés des nombres de 1 à 10"
# Votre code ici

puts "\n4. Comptez le nombre de voyelles dans cette phrase"
phrase = "Ruby est un langage formidable"
# Votre code ici

puts "\n5. Inversez chaque mot dans ce tableau"
mots_exercice = ["bonjour", "monde", "ruby"]
# Votre code ici (résultat attendu: ["ruojnob", "ednom", "ybur"])