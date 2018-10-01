require 'app/models/task'

class TaskCloseInteractor
  attr_accessor :task
  
  def initialize(task:)
    raise ArgumentError, 'Task required' unless task.is_a? Task
    
    @task = task
  end
  
  def process!
    move_state!
  end
  
  private
  
  def move_state!
    @task.close!
  end
end