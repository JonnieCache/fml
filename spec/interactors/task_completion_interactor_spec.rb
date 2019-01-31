require 'app/interactors/task_completion_interactor'

describe TaskCompletionInteractor do
  let(:task) {create :task, value: 100}
  let(:time) {Time.new 2019, 1, 1}
  let(:interactor) {TaskCompletionInteractor.new(task: task, time: time)}
  
  it 'returns a valid completion' do
    completion = interactor.process!
    
    expect(completion).to be_a Completion
    expect(completion).to be_valid
  end
  
  it 'assigns the value' do
    completion = interactor.process!
    
    expect(completion.value).to eq 100
  end
  
  it 'updates the task' do
    interactor.process!
    
    expect(task.last_completed_at).to eq time
  end
  
end
