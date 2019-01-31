require 'app/models/task'

class Nomination < Sequel::Model
  plugin :validation_helpers
  
  many_to_one :user
  many_to_one :essential_task, class_name: 'Task'
  many_to_one :nice_task_1, class_name: 'Task'
  many_to_one :nice_task_2, class_name: 'Task'
  
  def validate
    super
    
    validates_presence :user_id
  end
  
  def priority(task_or_id)
    task_id = task_or_id.is_a?(Task) ? task_or_id.id : task_or_id
    
    if task_id == essential_task_id
      0
    elsif task_id == nice_task_1_id
      1
    elsif
      task_id == nice_task_2_id
      2
    else
      nil
    end
  end
  
end
