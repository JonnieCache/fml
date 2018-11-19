require 'spec/integration_spec_helper'

describe 'Task UI' do
  let!(:user) {create :user}
  before {AuthenticatedController.test_user = user}
  
  describe 'Creating a task' do
    
    context 'with a preexisting task' do
    let!(:task2) {create :task, user: user, name: 'other task'}
    
      it 'creates the task' do
        go_home
        add_new_task name: 'test', tag: 'mytag', recurring: false
        # sleep 1; binding.pry; 
        
        sleep 0.1 
        
        expect(page).to have_task(name: 'test', tag: 'mytag', recurring: false).and have_task(name: 'other task')
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
  
end
