require 'spec/integration_spec_helper'

describe 'Search UI' do
  let!(:user) {create :user}
  before {AuthenticatedController.test_user = user}

  context 'with preexisting tasks' do
    let!(:tag) {create :tag, user: user, name: 'learning'}
    let!(:task1) {create :task, value: 1, name: 'go to school', user: user, tag: tag}
    let!(:task2) {create :task, value: 2, name: 'finish school', user: user, tag: tag}
    let!(:task3) {create :task, value: 3, name: 'eat breakfast', user: user, tag: tag}
    let!(:task4) {create :task, value: 4, name: 'go to work', user: user, tag: tag}

    describe 'hitting escape' do

      it 'closes the search box' do
        go_home
        open_search

        fill_in 'search-term', with: 'go to'

        page.find('body').send_keys :escape

        expect(page).to have_no_modal
      end
    end

    describe 'Searching a task' do

      context 'searching from start' do
        it 'finds the right task' do
          go_home
          open_search

          fill_in 'search-term', with: 'go to'


          expect(page).to have_search_result 'go to school'
          expect(page).to have_search_result 'go to work'
          expect(page).to_not have_search_result 'finish school'
          expect(page).to_not have_search_result 'eat breakfast'
        end
      end

      context 'searching from middle' do
        it 'finds the right task' do
          go_home
          open_search

          fill_in 'search-term', with: 'school'

          expect(page).to have_search_result 'go to school'
          expect(page).to have_search_result 'finish school'
          expect(page).to_not have_search_result 'eat breakfast'
        end
      end
    end

    describe 'Completing a task' do
      it 'completes the task' do
        go_home
        open_search
        fill_in 'search-term', with: 'go to school'

        find_field('search-term').send_keys :enter

        expect(page).to have_no_modal
        expect(score).to eq 1

      end

      it 'doesnt affect the UI afterwards' do
        go_home
        open_search
        fill_in 'search-term', with: 'go to school'
        find_field('search-term').send_keys :enter

        card = find_task_element(task3)
        within(card) {click_on 'Complete!'}

        sleep 0.1
        expect(score).to eq 7

      end
    end
  end

  context 'having added tasks in app' do
    it 'finds the right task' do
      go_home
      add_new_task name: 'go to school', tag: 'mytag'
      open_search

      fill_in 'search-term', with: 'go to'

      expect(page).to have_search_result 'go to school', selected: true
      expect(page).to_not have_search_result 'finish school'
      expect(page).to_not have_search_result 'eat breakfast'
    end
  end

end
