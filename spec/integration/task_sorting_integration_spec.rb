require 'spec/integration_spec_helper'

describe 'Task Sorting' do
  let!(:user) {create :user}
  before {AuthenticatedController.test_user = user}
  
  describe 'nominating' do
    let!(:foo)  {create :tag, name: 'foo', user: user}
    let!(:task) {create :task, name: 'the task', user: user, tag: foo}
    
    it 'nominates the essential task' do
      go_home
      goto_rows
      
      row = find_task_row task
      essential = find_task_slot :essential
      
      drag_drop row, essential
      
      expect(essential).to have_task_row task
      expect(user.nominations.last.essential_task).to eq task
    end
    
    it 'nominates nice task 1' do
      go_home
      goto_rows
      
      row = find_task_row task
      essential = find_task_slot :nice_task_1
      
      drag_drop row, essential
      expect(essential).to have_task_row task
      expect(user.nominations.last.nice_task_1).to eq task
    end
    
    it 'nominates nice task 2' do
      go_home
      goto_rows
      
      row = find_task_row task
      essential = find_task_slot :nice_task_2
      
      drag_drop row, essential
      expect(essential).to have_task_row task
      expect(user.nominations.last.nice_task_2).to eq task
    end
    
    it 'unnominates the essential task' do
      TaskSortingInteractor.new(user: user, essential_task: task, task_order: [task.id]).process!
      go_home
      goto_rows
      
      row = find_task_row task
      rest = find_task_slot :rest
      
      drag_drop row, rest
      
      expect(find_task_slot(:essential)).to_not have_task_row task
      expect(user.nominations.last.essential_task).to_not eq task
    end
    
    it 'unnominates nice task 1' do
      task2 = create :task, value: 2, name: 'the task2', user: user, tag: foo, recurring: true
      TaskSortingInteractor.new(user: user, essential_task: task2, nice_task_1: task, task_order: [task.id, task2.id]).process!
      go_home
      goto_rows
      expect(find_task_slot(:essential)).to have_task_row task2
      
      row = find_task_row task
      rest = find_task_slot :rest
      
      drag_drop row, rest
      
      expect(find_task_slot(:nice_task_1)).to_not have_task_row task
      expect(find_task_slot(:essential)).to have_task_row task2
      expect(user.nominations.last.nice_task_1).to_not eq task
    end
    
    it 'unnominates nice task 2' do
      TaskSortingInteractor.new(user: user, nice_task_2: task, task_order: [task.id]).process!
      go_home
      goto_rows
      
      row = find_task_row task
      rest = find_task_slot :rest
      
      drag_drop row, rest
      
      expect(find_task_slot(:nice_task_2)).to_not have_task_row task
      expect(user.nominations.last.nice_task_2).to_not eq task
    end
    
    it 'moves from nice task 2 to essential' do
      TaskSortingInteractor.new(user: user, nice_task_2: task, task_order: [task.id]).process!
      go_home
      goto_rows
      
      row = find_task_row task
      essential = find_task_slot :essential
      
      drag_drop row, essential

      
      expect(find_task_slot(:nice_task_2)).to_not have_task_row task
      expect(user.nominations.last.nice_task_2).to_not eq task
      
      expect(find_task_slot(:essential)).to have_task_row task
      expect(user.nominations.last.essential_task).to eq task
    end
    
    describe 'shuffling' do
      let!(:task2) {create :task, name: 'the task 2', user: user, tag: foo}
      let!(:task3) {create :task, name: 'the task 3', user: user, tag: foo}
      let!(:task4) {create :task, name: 'the task 4', user: user, tag: foo}
      let!(:task5) {create :task, name: 'the task 5', user: user, tag: foo}
      
      it 'works' do
        TaskSortingInteractor.new(user: user, essential_task: task, task_order: [task.id, task2.id, task3.id, task4.id, task5.id]).process!
        go_home
        goto_rows
        
        expect(task2).to appear_after(task)
        expect(task3).to appear_after(task2)
        expect(task4).to appear_after(task3)
        expect(task5).to appear_after(task4)
        
        drag_drop task2, task5
        
        expect(task2).to appear_after(task5)
      end
    end
    
  end
end
