require 'app/controllers/authenticated_controller'
require 'app/presenters/state_presenter'
require 'app/models/task'

class TagsController < AuthenticatedController
  route do |r|
    r.put do
      @tag = user.tags_dataset.first(id: jparams['id'])
      @tag.update jparams.except('id', "need")
      
      StatePresenter.new(user, tasks: [], tags: @tag).to_json
    end  
  end
end
