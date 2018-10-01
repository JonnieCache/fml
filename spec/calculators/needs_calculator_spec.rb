require 'app/calculators/needs_calculator'
require 'app/interactors/task_completion_interactor'

describe NeedsCalculator do
  let(:user)  {create :user}
  let!(:foo)  {create :tag, name: 'foo', user: user, goal_per_week: 10}
  let!(:bar)  {create :tag, name: 'bar', user: user, goal_per_week: 100}
  let(:task1) {create :task, value: 1, tag: foo, recurring: true, user: user}
  let(:task2) {create :task, value: 2, tag: bar, recurring: true, user: user}
  before do
    TaskCompletionInteractor.new(task: task1, time: Time.new(2017,1,1,0)).process!
    TaskCompletionInteractor.new(task: task2, time: Time.new(2017,1,1,1)).process!
  end
  
  it 'sets the right needs' do
    calc = NeedsCalculator.new([foo, bar], user: user, time: Time.new(2017,1,1,5))
    calc.calculate!
    
    expect(foo.need).to eq 0.1
    expect(bar.need).to eq 0.02
  end
end
