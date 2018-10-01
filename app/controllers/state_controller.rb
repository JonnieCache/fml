require 'app/controllers/authenticated_controller'
require 'app/presenters/state_presenter'

class StateController < AuthenticatedController
  route do |r|
    r.get do
      StatePresenter.new(user).to_json
    end
  end
  
end
