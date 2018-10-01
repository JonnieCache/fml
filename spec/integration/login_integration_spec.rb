require 'spec/integration_spec_helper'

describe 'Login UI' do
  let!(:user) {create :user, email: 'foo@bar.com', password: 'lol'}
  
  it 'can browse from signup to login'do
    visit '#/signup'
    click_on 'Log in here'
    
    expect(current_fragment).to eq '/login'
  end
  
  describe 'with the right credentials' do
    
    it 'logs in' do
      visit '/#/login'
      
      fill_in 'login', with: 'foo@bar.com'
      fill_in 'password', with: 'lol'
      
      click_on 'Login'
      sleep 0.5
      
      expect(current_fragment).to eq '/tasks'
    end
    
  end
  
  describe 'with the wrong credentials' do
    
    it 'doesnt log in', ignored_js_errors: '401 (Unauthorized)' do
      visit '/#/login'
      
      fill_in 'login', with: 'foo@bar.com'
      fill_in 'password', with: 'lolllll'
      
      click_on 'Login'
      sleep 0.5
      
      expect(current_fragment).to eq '/login'
      expect(page).to have_content 'Incorrect'
    end
    
  end
end
