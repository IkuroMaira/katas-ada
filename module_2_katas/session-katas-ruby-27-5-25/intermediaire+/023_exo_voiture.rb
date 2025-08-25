# Exercice 23 : Crée une classe Voiture avec des attributs (marque, modèle, année) et des méthodes (démarrer, arrêter, accélérer).

class Voiture
  def initialize(marque, modele, annnee)
    @marque = marque
    @modele = modele
    @annee = annnee
  end

  def demarrer
    puts "La #{@marque} #{@modele} démarre !"
  end

  def arreter
    puts "La #{@marque} #{@modele} s'arrête !"
  end

  def accelerer
    puts "La #{marque} #{@modele} accélère !"
  end

  def marque
    @marque
  end
end

ma_voiture = Voiture.new('Peugeot', '106kid', 1993)
ta_voiture = Voiture.new('Renault', 'Saxo', 2015)

ma_voiture.demarrer
ta_voiture.demarrer
ta_voiture.arreter
ma_voiture.accelerer