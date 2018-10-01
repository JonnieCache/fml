require 'app/controllers/authenticated_controller'
require 'app/interactors/task_completion_interactor'
require 'app/presenters/state_presenter'
require 'app/models/task'

class TasksController < AuthenticatedController
  route do |r|  
    r.get do
      user.tasks_ordered.to_json
    end
    
    r.get '/new' do
      @task = Task.new
      
      haml :new
    end
    
    r.post String, 'completions' do
      @task = user.tasks_dataset.first(id: request.captures[0])
      halt 404 unless @task
      
      @completion = TaskCompletionInteractor.new(task: @task).process!
      
      StatePresenter.new(user, tasks: @task, tags: @task.tag).to_json
    end
    
    r.post do
      @task = Task.create(jparams.merge(user_id: user.id))
      
      StatePresenter.new(user, tasks: @task, completions: [], tags: @task.tag).to_json
    end
    
    r.put do
      @task = user.tasks_dataset.first(id: jparams['id'])
      old_tag = @task.tag
      @task.update jparams.except('id')
      
      tags = []
      tags << @task.tag if @task.tag
      tags << old_tag if old_tag && old_tag != @task.tag
      
      StatePresenter.new(user, tasks: @task, tags: tags, completions: []).to_json
    end
    
    r.put 'order' do
      user.update(task_order: jparams['task_order'])
      
      nil
    end
    
  end
  
end
