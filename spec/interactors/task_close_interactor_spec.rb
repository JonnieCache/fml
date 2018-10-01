require 'app/interactors/task_completion_interactor'

describe TaskCompletionInteractor do
  let(:task) {create :task, value: 100}
  let(:interactor) {TaskCompletionInteractor.new(task: task)}
  let(:completion) {interactor.process!}
  
  it 'returns a valid completion' do
    expect(completion).to be_a Completion
    expect(completion).to be_valid
  end
  
  it 'assigns the value' do
    expect(completion.value).to eq 100
  end
end