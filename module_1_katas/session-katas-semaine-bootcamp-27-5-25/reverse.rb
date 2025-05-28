# Ecrire une méthode qui retourne un array inversé:
# array = [1, 2, 3, 4, 5]
# reverse_array = [5, 4, 3, 2, 1]

def reverse(arr)
  puts "Mon tableau à inverser: #{arr}"
  array_to_fill = []

  i = arr.length
  while i > 0 do
    i = i-1
    array_to_fill.push(arr[i])
  end

  print array_to_fill
  return array_to_fill
end

reverse(array)

