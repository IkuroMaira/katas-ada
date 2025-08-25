require_relative '../debutant/005_exo_even_or_odd'

describe 'even_or_odd' do
  it 'identifies if the number is even' do
    expect(even_or_odd(12)).to eq("C'est un nombre pair")
  end

  it 'identifies if the number odd' do
    expect(even_or_odd(5)).to eq("C'est un nombre impair")
  end
end