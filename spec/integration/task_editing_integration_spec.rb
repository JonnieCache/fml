require 'spec/integration_spec_helper'

describe 'Task UI' do
  let!(:user) {create :user}
  before {AuthenticatedController.test_user = user}
  
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
  
end
