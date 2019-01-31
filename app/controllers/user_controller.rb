require 'app/controllers/authenticated_controller'
require 'app/interactors/task_sorting_interactor'

class UserController < AuthenticatedController
  route do |r|  
    r.put do
      # binding.pry; 
      user.update jparams['user'].except('id')
      
      if jparams['nomination']
        TaskSortingInteractor.new(user: user, task_order: jparams['user']['task_order'], **jparams['nomination'].symbolize_keys).process!
      end
      
      # response.status = 200
      # "{}"
      
      StatePresenter.new(user).to_json
    end
        
  end
  
end
