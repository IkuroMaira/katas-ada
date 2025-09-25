# Métaprogrammation en Ruby

puts "=== MÉTAPROGRAMMATION EN RUBY ==="

# 1. define_method - Créer des méthodes dynamiquement
class Personne
  attr_accessor :nom, :age, :email

  # Créer des méthodes de validation dynamiquement
  [:nom, :age, :email].each do |attribut|
    define_method "#{attribut}_valide?" do
      !instance_variable_get("@#{attribut}").nil?
    end
  end

  # Créer des méthodes de reset dynamiquement
  [:nom, :age, :email].each do |attribut|
    define_method "reset_#{attribut}" do
      instance_variable_set("@#{attribut}", nil)
    end
  end

  def initialize(nom, age, email)
    @nom = nom
    @age = age
    @email = email
  end
end

puts "\n=== define_method ==="
p = Personne.new("Alice", 25, "alice@example.com")
puts "Nom valide? #{p.nom_valide?}"
puts "Age valide? #{p.age_valide?}"

p.reset_nom
puts "Nom après reset: #{p.nom}"
puts "Nom valide après reset? #{p.nom_valide?}"

# 2. method_missing - Intercepter les appels de méthodes inexistantes
class ConfigurationDynamique
  def initialize
    @parametres = {}
  end

  def method_missing(method_name, *args)
    method_str = method_name.to_s

    if method_str.end_with?('=')
      # Setter dynamique
      param_name = method_str.chomp('=')
      @parametres[param_name] = args.first
    elsif method_str.end_with?('?')
      # Vérification booléenne
      param_name = method_str.chomp('?')
      !!@parametres[param_name]
    else
      # Getter dynamique
      @parametres[method_str]
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    true
  end

  def afficher_config
    @parametres.each { |k, v| puts "#{k}: #{v}" }
  end
end

puts "\n=== method_missing ==="
config = ConfigurationDynamique.new
config.base_url = "https://api.example.com"
config.timeout = 30
config.debug = true

puts "Base URL: #{config.base_url}"
puts "Timeout: #{config.timeout}"
puts "Debug activé? #{config.debug?}"

config.afficher_config

# 3. send - Appeler des méthodes dynamiquement
class Calculatrice
  def additionner(a, b)
    a + b
  end

  def soustraire(a, b)
    a - b
  end

  def multiplier(a, b)
    a * b
  end

  def diviser(a, b)
    b != 0 ? a.to_f / b : "Division par zéro"
  end
end

puts "\n=== send ==="
calc = Calculatrice.new
operations = ['additionner', 'soustraire', 'multiplier', 'diviser']

operations.each do |op|
  resultat = calc.send(op.to_sym, 10, 2)
  puts "10 #{op} 2 = #{resultat}"
end

# 4. class_eval et instance_eval
class MaClasse
  def methode_instance
    "Je suis une méthode d'instance"
  end
end

# Ajouter des méthodes à une classe existante
MaClasse.class_eval do
  def nouvelle_methode
    "Méthode ajoutée dynamiquement"
  end

  define_method :methode_dynamique do |param|
    "Paramètre reçu: #{param}"
  end
end

puts "\n=== class_eval ==="
obj = MaClasse.new
puts obj.methode_instance
puts obj.nouvelle_methode
puts obj.methode_dynamique("Hello")

# instance_eval pour ajouter des méthodes singleton
obj.instance_eval do
  def methode_unique
    "Je n'existe que pour cette instance"
  end
end

puts obj.methode_unique

# 5. Modules avec hook methods
module Trackable
  def self.included(base)
    puts "Module Trackable inclus dans #{base}"
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end

  module ClassMethods
    def track(*method_names)
      method_names.each do |method_name|
        original_method = "#{method_name}_without_tracking"

        alias_method original_method, method_name

        define_method method_name do |*args, &block|
          puts "[TRACK] Appel de #{method_name} avec #{args}"
          result = send(original_method, *args, &block)
          puts "[TRACK] Résultat: #{result}"
          result
        end
      end
    end
  end

  module InstanceMethods
    def tracking_enabled?
      true
    end
  end
end

class ServiceAPI
  include Trackable

  def rechercher(terme)
    "Résultats pour: #{terme}"
  end

  def sauvegarder(data)
    "Données sauvegardées: #{data}"
  end

  track :rechercher, :sauvegarder
end

puts "\n=== Hook methods ==="
service = ServiceAPI.new
service.rechercher("Ruby")
service.sauvegarder({nom: "Test"})

# 6. Création de DSL (Domain Specific Language)
class ConstructeurHTML
  def initialize
    @html = []
  end

  def method_missing(tag, *args, &block)
    attributes = args.first.is_a?(Hash) ? args.first : {}
    content = args.last.is_a?(String) ? args.last : nil

    @html << "<#{tag}#{format_attributes(attributes)}>"

    if block_given?
      old_html = @html.dup
      @html.clear
      instance_eval(&block)
      inner_html = @html.join("\n")
      @html = old_html
      @html << inner_html
    elsif content
      @html << content
    end

    @html << "</#{tag}>"
  end

  def to_html
    @html.join("\n")
  end

  private

  def format_attributes(attrs)
    return "" if attrs.empty?
    " " + attrs.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
  end
end

puts "\n=== DSL pour HTML ==="
html = ConstructeurHTML.new
html.instance_eval do
  html do
    head do
      title "Ma Page"
    end
    body class: "main" do
      h1 "Bienvenue"
      p "Ceci est un paragraphe"
      div id: "content", "Contenu principal"
    end
  end
end

puts html.to_html

# 7. const_missing pour lazy loading
module LazyLoader
  def self.const_missing(name)
    puts "Tentative de chargement de la constante: #{name}"

    case name
    when :DatabaseConnection
      const_set(name, Class.new do
        def self.connect
          "Connexion à la base de données"
        end
      end)
    when :CacheService
      const_set(name, Class.new do
        def self.get(key)
          "Valeur depuis le cache pour: #{key}"
        end
      end)
    else
      super
    end
  end
end

puts "\n=== const_missing ==="
puts LazyLoader::DatabaseConnection.connect
puts LazyLoader::CacheService.get("user:123")

# 8. Singleton methods et eigenclass
class MonObjet
  def methode_normale
    "Je suis normale"
  end
end

obj = MonObjet.new

# Ajouter une méthode singleton
def obj.methode_speciale
  "Je n'existe que pour cet objet"
end

# Ou avec define_singleton_method
obj.define_singleton_method :autre_methode do
  "Autre méthode singleton"
end

puts "\n=== Singleton methods ==="
puts obj.methode_normale
puts obj.methode_speciale
puts obj.autre_methode

# Accéder à l'eigenclass
eigenclass = class << obj; self; end
puts "Eigenclass: #{eigenclass}"

# 9. Proxy objects avec method_missing
class ServiceProxy
  def initialize(service_name)
    @service_name = service_name
    @cache = {}
  end

  def method_missing(method_name, *args)
    cache_key = "#{method_name}_#{args.hash}"

    if @cache.key?(cache_key)
      puts "[CACHE] Récupération depuis le cache"
      return @cache[cache_key]
    end

    puts "[PROXY] Appel de #{@service_name}.#{method_name}(#{args})"

    # Simulation d'un appel de service
    result = "Résultat de #{method_name} avec #{args}"
    @cache[cache_key] = result

    result
  end

  def respond_to_missing?(method_name, include_private = false)
    true
  end
end

puts "\n=== Proxy objects ==="
proxy = ServiceProxy.new("UserService")
puts proxy.find_user(123)  # Premier appel
puts proxy.find_user(123)  # Depuis le cache
puts proxy.update_user(123, {name: "John"})

# 10. Création d'attributs avec comportement personnalisé
module AttributsPersonnalises
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def typed_attr(name, type)
      define_method name do
        instance_variable_get("@#{name}")
      end

      define_method "#{name}=" do |value|
        unless value.is_a?(type)
          raise TypeError, "#{name} doit être de type #{type}, #{value.class} donné"
        end
        instance_variable_set("@#{name}", value)
      end
    end

    def lazy_attr(name, &block)
      define_method name do
        var_name = "@#{name}"
        if instance_variable_defined?(var_name)
          instance_variable_get(var_name)
        else
          value = instance_eval(&block)
          instance_variable_set(var_name, value)
        end
      end
    end
  end
end

class Utilisateur
  include AttributsPersonnalises

  typed_attr :nom, String
  typed_attr :age, Integer

  lazy_attr :id do
    puts "Génération de l'ID..."
    rand(1000..9999)
  end

  def initialize(nom, age)
    self.nom = nom
    self.age = age
  end
end

puts "\n=== Attributs personnalisés ==="
user = Utilisateur.new("Alice", 25)
puts "Nom: #{user.nom}"
puts "ID (première fois): #{user.id}"
puts "ID (depuis cache): #{user.id}"

# Test de validation de type
begin
  user.age = "trente"  # Erreur attendue
rescue TypeError => e
  puts "Erreur capturée: #{e.message}"
end

puts "\n=== Fin de la métaprogrammation Ruby ==="