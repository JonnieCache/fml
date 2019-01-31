require 'app/interactors/task_sorting_interactor'

describe TaskSortingInteractor do
  let(:user)  {create :user}
  let(:task)  {create :task, value: 100, user: user}
  let(:task2) {create :task, value: 50, user: user}
  let(:date)  {Date.new 2019, 1, 1}
  
  it 'works' do
    sorter = TaskSortingInteractor.new(user: user, essential_task: task, nice_task_1: task2, task_order: [task.id, task2.id], date: date)
    sorter.process!
    
    nomination = DB[:nominations].first(nominated_for: date)
    expect(nomination[:essential_task_id]).to eq task.id
    expect(nomination[:nice_task_1_id]).to eq task2.id
    
    sorter2 = TaskSortingInteractor.new(user: user, essential_task: task2, nice_task_1: task, task_order: [task2.id, task.id], date: date)
    sorter2.process!
    
    nomination2 = DB[:nominations].first(nominated_for: date)
    expect(nomination2[:essential_task_id]).to eq task2.id
    expect(nomination2[:nice_task_1_id]).to eq task.id
    expect(nomination2[:id]).to eq nomination[:id]
  end
end
