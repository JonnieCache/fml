require 'app/models/nomination'

describe :nomination do
  let(:nomination) {create :nomination}
  
  it 'is valid' do
    expect(nomination).to be_valid
  end
end
