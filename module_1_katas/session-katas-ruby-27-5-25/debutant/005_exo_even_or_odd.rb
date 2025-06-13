def even_or_odd(number)
  if number % 2 === 0
    return "C'est un nombre pair"
  else
    return "C'est un nombre impair"
  end
end

puts even_or_odd(12)
puts even_or_odd(5)