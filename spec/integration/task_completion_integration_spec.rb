require 'spec/integration_spec_helper'

describe 'Task UI' do
  let!(:user) {create :user}
  before {AuthenticatedController.test_user = user}
  
  describe 'completing a task' do
    let!(:foo)  {create :tag, name: 'foo', user: user}
    let!(:bar)  {create :tag, name: 'bar', user: user}
    let!(:task) {create :task, value: 2, name: 'the task', user: user, tag: foo, recurring: true}
    let!(:task2) {create :task, value: 4, user: user, name: 'other task', tag: bar, recurring: false}
    
    context 'with a recurring task' do
      it 'completes the task, leaves it on the page' do
        go_home
        card = find_task_card(task)

        within(card) {click_on 'Complete!'}
        expect(page).to have_content 'Score: 2'
        expect(page).to have_content 'Combo: 1x'
        expect(page).to have_task(name: 'the task').and have_task(name: 'other task')
      end
    end
    
    context 'with a nonrecurring task' do
      it 'completes the task, removes it from the page' do
        go_home
        card = find_task_card(task2)

        within(card) {click_on 'Complete!'}
        expect(page).to have_content 'Score: 4'
        expect(page).to have_content 'Combo: 1x'
        expect(page).to have_task(name: 'the task')
        expect(page).to_not have_content('other task')
      end
    end
  end
end
