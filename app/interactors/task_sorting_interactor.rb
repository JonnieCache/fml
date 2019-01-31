require 'app/models/task'
require 'app/models/user'
require 'app/models/nomination'
require 'lib/fml_logger'

class TaskSortingInteractor
  include FMLLogger
  
  attr_accessor :task, :nomination

  def initialize(user:, task_order: [], essential_task: nil, nice_task_1: nil, nice_task_2: nil, date: Date.today+1)
    raise ArgumentError, 'User required' unless user.is_a? User

    @user = user
    @date = date
    # binding.pry; 
    @task_order = task_order.map {|task_or_id| task_or_id.is_a?(Task) ? task_or_id.id : task_or_id}
    
    @essential_task_id = essential_task.is_a?(Task) ? essential_task.id : essential_task
    # @essential_task_id = nil if @essential_task_id === false
    @nice_task_1_id = nice_task_1.is_a?(Task) ? nice_task_1.id : nice_task_1
    @nice_task_2_id = nice_task_2.is_a?(Task) ? nice_task_2.id : nice_task_2
  end

  def process!
    @user.update task_order: @task_order
    update = {
      essential_task_id: @essential_task_id,
      nice_task_1_id: @nice_task_1_id,
      nice_task_2_id: @nice_task_2_id
    }.compact
    update.each {|k,v| update[k] = nil if v === false}
    # binding.pry; 
    @nomination = Nomination.find_or_create(
      nominated_for: @date,
      user: @user
    )
    # binding.pry; 
    @nomination.update(update)
    
    logger.debug Paint["NOMINATED: #{@nomination.ai}", :magenta]
    logger.debug Paint["ESSENTIAL: #{@nomination.essential_task}", :magenta]
    logger.debug Paint["NICE1: #{@nomination.nice_task_1}", :magenta]
    logger.debug Paint["NICE2: #{@nomination.nice_task_2}", :magenta]
    
    @nomination
  end
  
end
