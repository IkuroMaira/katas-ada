class Animal
  def initialize(nom, age)
    @nom = nom
    @age = age
  end

  def manger
    puts "#{@nom} mange"
  end

  def dormir
    puts "#{@nom} dort"
  end

  def afficher_infos
    puts "#{@nom} a #{@age} ans"
  end
end

class Chien < Animal
  def initialize(nom, age, race)
    super(nom, age)
    @race = race
  end

  def aboyer
    puts "Le chien aboie"
  end

  def afficher_infos
    super  # Appelle la méthode du parent
    puts "Race: #{@race}"
  end
end

class Chat < Animal
  def initialize(nom, age)
    super(nom, age)
  end

  def miauler
    puts "Le chat miaule"
  end
end

chat = Chat.new("Maïtika", 3)
chat.miauler
chat.dormir
chat.manger
chien = Chien.new("Pluto", 5, "labrador")
chien.aboyer
chien.afficher_infos

puts "3. Tous peuvent faire les actions de base (héritage):"
animaux = [chat, chien]

animaux.each do |animal|
  animal.manger  # Tous héritent de cette méthode
end