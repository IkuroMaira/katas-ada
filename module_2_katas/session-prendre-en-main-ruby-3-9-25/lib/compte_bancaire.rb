class Banque
  # Constantes de classe (accessibles avec ::)
  TAUX_INTERET = 0.02
  FRAIS_TRANSFERT = 1.5
  NOM_BANQUE = "Banque de Gwen"

  # Méthode de classe (accessible avec ::)
  def self.calculer_interets(montant, duree_mois)
    montant * TAUX_INTERET * duree_mois / 12
  end

  # Méthode de classe pour afficher les infos
  def self.infos_banque
    "#{NOM_BANQUE} - Taux: #{TAUX_INTERET * 100}% - Frais: #{FRAIS_TRANSFERT}€"
  end
end

class CompteBancaire
  def initialize(client, solde_initial = 0)
    @titulaire = client
    @solde = solde_initial
    @historique = []
  end

  def deposer(montant)
    if montant > 0
      @solde += montant
      @historique << "+#{montant}€"
      # "<<" permet d'ajouter des élément au tableau ("Shovel Operator" ou "append operator"). Il ajoute un élément à la fin d'un tableau
      puts "Dépôt de #{montant}€ effectué"
    else
      puts "Le montant doit être positif"
    end
  end

  def retirer(montant)
    if montant > 0 && montant <= @solde
      @solde -= montant
      @historique << "-#{montant}€"
      puts "Retrait de #{montant}€ effectué"
    elsif montant > @solde
      puts "Solde insuffisant"
    else
      puts "Le montant doit être positif"
    end
  end

  def afficher_solde
    puts "#{@titulaire} a #{@solde} €"
  end

  def afficher_historique
    puts "HISTORIQUE"

    if @historique.empty?
      puts "Aucune opération"
    elsif
      @historique.each do |operation|
        puts "#{operation}"
      end
    end
  end

  def transferer_avec_frais(montant, autre_compte)
    # Utilisation de :: pour accéder à la constante de classe
    frais = Banque::FRAIS_TRANSFERT
    montant_total = montant + frais

    if montant > 0 && montant_total <= @solde
      @solde -= montant_total
      @historique << "Transfert: -#{montant}€ (frais: #{frais}€)"
      puts "Transfert de #{montant}€ effectué (frais: #{frais}€)"
    elsif montant_total > @solde
      puts "Solde insuffisant (frais de #{frais}€ inclus)"
    else
      puts "Le montant doit être positif"
    end
  end

  def calculer_interets_futurs(duree_mois)
    # Utilisation de :: pour appeler une méthode de classe
    interets = Banque::calculer_interets(@solde, duree_mois)
    puts "Avec #{@solde}€ pendant #{duree_mois} mois, vous gagnerez #{interets.round(2)}€ d'intérêts"
    interets
  end

  # méthode pour accéder au solde
  def solde
    @solde
  end
end

puts "=== Utilisation de l'opérateur :: ==="
puts

# 1. Accès aux constantes avec ::
puts "Nom de la banque: #{Banque::NOM_BANQUE}"
puts "Taux d'intérêt: #{Banque::TAUX_INTERET * 100}%"
puts "Frais de transfert: #{Banque::FRAIS_TRANSFERT}€"
puts

# 2. Appel de méthodes de classe avec ::
puts Banque::infos_banque
puts

# 3. Calcul d'intérêts directement via la classe
interets = Banque::calculer_interets(1000, 6)
puts "Intérêts sur 1000€ pendant 6 mois: #{interets}€"
puts

# 4. Test avec un compte
puts "=== Test du compte ==="
mon_compte = CompteBancaire.new("Gwen", 500)
mon_compte.afficher_solde
mon_compte.transferer_avec_frais(100, "compte épargne")
mon_compte.calculer_interets_futurs(12)
mon_compte.afficher_historique