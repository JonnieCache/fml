require 'spec/integration_spec_helper'

describe 'Signup UI' do
  let!(:user) {create :user, email: 'foo@bar.com', password: 'foobar'}
  
  it 'can browse from login to signup', ignored_js_errors: '401 (Unauthorized)' do
    visit '#/login'
    click_on 'Sign up'
    
    expect(current_fragment).to eq '/signup'
  end
  
  describe 'with good credentials' do
    
    it 'signups up' do
      visit '/#/signup'
      
      fill_in 'login', with: 'abc@bar.com'
      fill_in 'password', with: 'foobar'
      fill_in 'password-confirm', with: 'foobar'
      click_on 'Signup'
      
      sleep 0.5
      expect(current_fragment).to eq '/tasks'
    end
    
  end
  
  describe 'with non matching passwords' do
    
    it 'doesnt log in', ignored_js_errors: '422 (Unprocessable Entity)' do
      visit '/#/signup'
      
      fill_in 'login', with: 'foo@bar.com'
      fill_in 'password', with: 'lolllll'
      fill_in 'password-confirm', with: 'foobar'
      click_on 'Signup'
      
      sleep 0.5
      expect(current_fragment).to eq '/signup'
    end
    
  end
end
