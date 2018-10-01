require 'spec/integration_spec_helper'

describe 'Task UI' do
  let!(:user) {create :user}
  before {AuthenticatedController.test_user = user}
  
  describe 'Creating a task' do
    
    context 'with a preexisting task' do
    let!(:task2) {create :task, user: user, name: 'other task'}
    
      it 'creates the task' do
        go_home
        add_new_task name: 'test', tag: 'mytag'
        sleep 0.1
        expect(page).to have_task(name: 'test', tag: 'mytag').and have_task(name: 'other task')
        expect(page).to have_no_modal
      end
    end
    
    context 'without a preexisting task' do
      it 'creates the task' do
        go_home
        # sleep 2; binding.pry; 
        add_new_task name: 'test', tag: 'mytag'
        # sleep 2; binding.pry; 
        
        sleep 0.1
        expect(page).to have_task(name: 'test', tag: 'mytag')
        expect(page).to have_no_modal
      end
    end
    
    it 'wipes the new task upon cancelling' do
      go_home
      open_new_task_form
      fill_in_task_form(name: 'lol', value: 100, recurring: false)
      click_on 'Cancel'
      sleep 1
      
      open_new_task_form
      
      expect(page).to have_field('Name', with: '')
      expect(page).to have_field('Value', with: 1)
      expect(page).to have_checked_field('Recurring')
    end
  end
  
  describe 'Editing a task' do
    let!(:task) {create :task, name: 'the task', user: user, recurring: true}
    let!(:task2) {create :task, user: user, name: 'other task', recurring: true}
    
    it 'edits the task' do
      go_home
      edit_task original: {name: 'the task'}, name: 'lmao'
      
      expect(page).to have_task(name: 'lmao').and have_task(name: 'other task')
      expect(page).to have_no_modal
    end
    
    it 'reset the edited task upon cancelling' do
      go_home
      open_edit_task_form(name: 'the task')
      fill_in_task_form(name: 'lol', value: 1, recurring: false)
      click_on 'Cancel'
      
      open_edit_task_form(name: 'the task')
      
      expect(page).to have_field('Name', with: 'the task')
      expect(page).to have_field('Value', with: 10)
      expect(page).to have_checked_field('Recurring')
    end
  end
  
  describe 'completing a task' do
    let!(:foo)  {create :tag, name: 'foo', user: user}
    let!(:bar)  {create :tag, name: 'bar', user: user}
    let!(:task) {create :task, value: 2, name: 'the task', user: user, tag: foo, recurring: true}
    let!(:task2) {create :task, value: 4, user: user, name: 'other task', tag: bar, recurring: false}
    
    context 'with a recurring task' do
      it 'completes the task, leaves it on the page' do
        go_home
        card = find_task_element(task)

        within(card) {click_on 'Complete!'}
        expect(page).to have_content 'Score: 2'
        expect(page).to have_content 'Combo: 1x'
        expect(page).to have_task(name: 'the task').and have_task(name: 'other task')
      end
    end
    
    context 'with a nonrecurring task' do
      it 'completes the task, removes it from the page' do
        go_home
        card = find_task_element(task2)

        within(card) {click_on 'Complete!'}
        expect(page).to have_content 'Score: 4'
        expect(page).to have_content 'Combo: 1x'
        expect(page).to have_task(name: 'the task')
        expect(page).to_not have_content('other task')
      end
    end
  end
end
