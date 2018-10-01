require 'app/models/user'
require 'app/interactors/task_completion_interactor'
require 'app/presenters/state_presenter'

describe StatePresenter do
  let(:user)  {create :user}
  let!(:foo)  {create :tag, name: 'foo', user: user}
  let!(:bar)  {create :tag, name: 'bar', user: user}
  let(:task1) {create :task, value: 1, tag: create(:tag, name: 'foo', user: user), recurring: true, user: user}
  let(:task2) {create :task, value: 2, tag: create(:tag, name: 'bar', user: user), recurring: true, user: user}
  before do
    TaskCompletionInteractor.new(task: task1, time: Time.new(2017,1,1,0)).process!
    TaskCompletionInteractor.new(task: task2, time: Time.new(2017,1,1,1)).process!
  end
  
  it 'renders correctly' do
    pres = StatePresenter.new(user, time: Time.new(2017,1,1,5))
    
    # ap pres.render
  end
end
