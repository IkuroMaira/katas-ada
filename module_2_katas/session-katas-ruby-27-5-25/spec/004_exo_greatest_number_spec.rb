require_relative '../debutant/004_exo_greatest_number'

describe 'greatest_number' do
  it 'identifies that the first number is the greatest number' do
    expect(greatest_number(15, 1)).to eq(15)
  end

  it 'identifies that the second number is the greatest number' do
    expect(greatest_number(5, 7)).to eq(7)
  end

  it 'identifies the equals numbers' do
    expect(greatest_number(11, 11)).to eq("Ce sont les mêmes nombres")
  end
end