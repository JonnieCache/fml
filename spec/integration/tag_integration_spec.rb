require 'spec/integration_spec_helper'

describe 'Tag UI' do
  let!(:user) {create :user}
  before {AuthenticatedController.test_user = user}
  
  describe 'Editing a tag' do
    let!(:tag) {create :tag, user: user, name: 'the tag'}
    let!(:task) {create :task, name: 'the task', user: user, tag: tag}
    
    it 'edits the tag' do
      go_home
      edit_tag original: {name: 'the tag'}, name: 'lmao'
      expect(page).to have_tag(name: 'lmao')
      expect(page).to have_no_modal
    end
    
    it 'doesnt update the tag until save is clicked' do
      go_home
      open_edit_tag_form name: 'the tag'
      fill_in_tag_form name: 'lmao'
      
      expect(page).to have_tag(name: 'the tag')
      
      click_on 'Save'
      
      expect(page).to have_tag(name: 'lmao')
      expect(page).to have_no_modal
    end
    
    # it 'reset the edited task upon cancelling' do
    #   go_home
    #   open_edit_task_form(name: 'the task')
    #   fill_in_task_form(name: 'lol', value: 1, recurring: true)
    #   click_on 'Cancel'
      
    #   open_edit_task_form(name: 'the task')
      
    #   expect(page).to have_field('Name', with: 'the task')
    #   expect(page).to have_field('Value', with: 10)
    #   expect(page).to_not have_checked_field('Recurring')
    # end
  end
end
