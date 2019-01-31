require 'app/models/task'
require 'app/interactors/task_completion_interactor'

describe Task do
  let(:task) {create :task}
  
  it 'is valid' do
    expect(task).to be_valid
  end
  
  context 'after completion' do
    before {TaskCompletionInteractor.new(task: task).process!}
    
    it 'is .complete?' do
      expect(task.complete?).to eq true
    end
    
    context 'recurring task' do
      let(:task) {create :task, recurring: true}
      
      it 'isnt .complete?' do
        expect(task.complete?).to eq false
      end
    end
  end
  
  describe '#finished?' do
    it 'is false when incomplete' do
      expect(task).to_not be_finished
    end
    
    it 'is true when complete' do
      task.complete!
      
      expect(task).to be_finished
    end
    
    it 'is true when closed' do
      task.close!
      
      expect(task).to be_finished
    end
  end
end
