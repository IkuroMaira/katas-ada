def displayMention(note)
  # puts "Donnez moi votre note : "
  if note <10
    puts "Insuffisant"
  elsif note >= 10 && note <12
    puts "Passable"
  elsif note >= 12 && note < 14
    puts "Assez bien"
  elsif note >= 14 && note < 16
    puts "Bien"
  elsif note >= 16
    puts "Très bien"
  end
end

displayMention(3)
displayMention(11)
displayMention(12)
displayMention(15)
displayMention(18)