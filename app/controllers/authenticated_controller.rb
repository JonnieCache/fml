require 'app/controllers/fml_controller'

class AuthenticatedController < FMLController
  class << self
    attr_accessor :test_user
    
    def get_test_user
      AuthenticatedController.test_user || self.test_user
    end
  end
  
  def user
    return self.class.get_test_user if self.class.get_test_user
    
    @user ||= User[rodauth.session[:account_id]]
  end
  
  before do
    unless self.class.get_test_user
      rodauth.require_login
      
      request.halt 401 unless user.is_a? User
    end
  end
end

