require 'app/models/user'

describe User do
  let(:user) {create :user}
  
  it 'is valid' do
    expect(user).to be_valid
  end
  
  describe 'task ordering' do
    let(:user) {create :user}
    let!(:task) {create :task, user_id: user.id}
    let!(:task2) {create :task, user_id: user.id}
    
    it 'works forwards' do
      user.task_order = [task2.id, task.id]
      user.save
      
      expect(user.tasks_ordered.first.id).to eq task2.id
      expect(user.tasks_ordered.last.id).to eq task.id
    end
    
    it 'works backwards' do
      user.task_order = [task.id, task2.id]
      user.save
      
      expect(user.tasks_ordered.first.id).to eq task.id
      expect(user.tasks_ordered.last.id).to eq task2.id
    end
    
    it 'works empty' do
      user.task_order = []
      user.save
      
      expect{user.tasks_ordered}.to_not raise_exception
      
      expect(user.tasks_ordered).to include task
      expect(user.tasks_ordered).to include task2
    end
  end
end