require 'app/controllers/tasks_controller'

describe TasksController do
  def app
    TasksController
  end
  
  context 'updating tag of a task' do
    let(:user) {create :user}
    let(:tag1) {create :tag, name: 'tag1', user: user}
    let(:tag2) {create :tag, name: 'tag2', user: user}
    let(:task) {create :task, name: 'test', user: user, tag: tag1}
    before {app.test_user = user}
    
    it 'returns the old tag as well as the new one' do
      req = {
        id: task.id,
        created_at: task.created_at,
        updated_at: nil,
        last_completed_at: nil,
        name: "test",
        description: "do a lot of work",
        recurring: false,
        value: 10,
        tag_id: tag2.id
      }
      
      jput '/', req
      
      expect(jresponse['tags'].values).to include(
        a_hash_including("id" => tag1.id),
        a_hash_including("id" => tag2.id)
      )
    end
  end
end
