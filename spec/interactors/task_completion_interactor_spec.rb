require 'app/interactors/task_close_interactor'

describe TaskCloseInteractor do
  let(:task) {create :task, value: 100}
  let(:interactor) {TaskCloseInteractor.new(task: task)}
  before {interactor.process!}
  
  it 'closes the task' do
    expect(task).to be_closed
  end
end