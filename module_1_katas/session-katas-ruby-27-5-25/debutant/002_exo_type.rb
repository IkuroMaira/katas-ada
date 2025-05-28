# Exercice 2 : Déclare différents types de variables (string, integer, float, boolean) et affiche leur type avec .class.

string = "Gwen"
integer = 21
float = 1.4
boolean = true
array = [1,2,3]

def display_type(object)
  puts object.class
end

display_type(string)
display_type(integer)
display_type(float)
display_type(boolean)
display_type(array)

puts "--------------------"

def type_of_object(obj)
  if obj.is_a?(String)
    "String"
  elsif obj.is_a?(Integer)
    "Integer"
  elsif obj.is_a?(Array)
    "Array"
  elsif obj.is_a?(Hash)
    "Hash"
  else
    "Unknown"
  end
end

obj1 = "Hello"
obj2 = 123
obj3 = [1, 2, 3]
obj4 = { key: "value" }

puts type_of_object(obj1)
puts type_of_object(obj2)
puts type_of_object(obj3)
puts type_of_object(obj4)