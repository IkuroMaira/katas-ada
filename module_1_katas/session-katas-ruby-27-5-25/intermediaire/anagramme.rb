# Le principe de l'anagramme c'est qu'on a:
# - le même nombre de lettre
# - les mêmes lettres mais pas dans le même ordre
# - ajouter après avoir vu sur internet la gestion des majuscules

def anagramme(firstword, secondword)
  puts "# Ma fonction anagramme"

  if firstword.length != secondword.length
    puts false
    puts "Ce ne sont pas des anagrammes"
    return false
  else
    puts firstword.downcase.chars.sort.join
    puts secondword.downcase.chars.sort.join

    if firstword.chars.sort.join === secondword.chars.sort.join
      puts true
      puts "Ce sont des anagrammes"
      return true
    end
  end
end

anagramme("chien", "niche")     # => true
anagramme("bonjour", "jourbon") # => true
anagramme("Bonjour", "jourbon") # => true
anagramme("bonjour", "hello")   # => false