require_relative '../debutant/006_exo_area_of_a_circle'

describe 'area_of_a_circle' do
  it 'give the good result' do
    expect(area_of_a_circle(3)).to eq(28.274333882308138)
  end
end