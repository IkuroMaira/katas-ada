def greatest_number(num1, num2)
  puts "Nombre 1: #{num1}, Nombre 2: #{num2}"

  if num1 > num2
    return "#{num1} est le plus grand"
  else
    return "#{num2} est le plus grand"
  end
end

puts greatest_number(1, 8)
puts greatest_number(7, 5)