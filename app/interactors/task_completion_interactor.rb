require 'app/models/task'
require 'app/models/completion'

class TaskCompletionInteractor
  attr_accessor :task, :completion
  
  def initialize(task:, time: Time.now)
    raise ArgumentError, 'Task required' unless task.is_a? Task
    
    @task = task
    @time = time
  end
  
  def process!
    create_completion!
    update_task!    
    
    @completion
  end
  
  private
  
  def create_completion!
    @completion = Completion.create(
      task: @task,
      created_at: @time,
      value: value,
      user_id: @task.user_id
    )
  end
  
  def update_task!
    @task.complete! unless @task.recurring?
    @task.last_completed_at = @time
    
    @task.save
  end
  
  def value
    @task.value
  end
end