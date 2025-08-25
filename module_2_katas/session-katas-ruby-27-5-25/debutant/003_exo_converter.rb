def converter(temp)
  puts "#{temp} Celsius"

  temp_fahrenheit = (temp * 1.8) + 32
  puts "#{temp_fahrenheit} Fahrenheit"

  temp_kelvin = temp + 273.15
  puts "#{temp_kelvin} Kelvin"
end

converter(30)