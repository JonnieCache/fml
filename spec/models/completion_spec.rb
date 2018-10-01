require 'app/models/completion'

describe Completion do
  let(:completion) {create :completion}
  
  it 'is valid' do
    expect(completion).to be_valid
  end
end