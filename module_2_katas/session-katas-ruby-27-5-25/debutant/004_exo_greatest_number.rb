def greatest_number(num1, num2)
  # puts "Nombre 1: #{num1}, Nombre 2: #{num2}"

  if num1 > num2
    return num1
  elsif num1 === num2
    return "Ce sont les mêmes nombres"
  else
    return num2
  end
end

puts greatest_number(1, 8)
puts greatest_number(7, 5)
puts greatest_number(9, 9)