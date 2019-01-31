require 'lib/fml_logger'

class ComboCalculator
  include FMLLogger
  
  ONE_DAY = 86400
  BONUS_PER_CONSECUTIVE_TASK = 0
  BONUS_PER_ESSENTIAL_TASK = 3
  BONUS_PER_NICE_TO_HAVE_TASK = 2
  
  PENALTY_PER_DAILY_TASK_MISSED = 0.5 
  
  def initialize(user, completions: nil, nominations: nil, time: Time.now)
    @user = user
    @completions = Array(completions || @user.completions_dataset.order(:created_at))
    @nominations = Array(nominations || @user.nominations_dataset.order(:nominated_for))
    @daily_tasks = user.tasks_dataset.where(state: 'incomplete', daily: true).all
    @time = time
    @time_passed = nil
  end
  
  def calculate!
    @score = 0
    @combo = 1
    last_date = nil
    
    logger.debug Paint["CALCULATING COMBO USERID: #{@user.id}", :blue]
    
    return result if @completions.empty?
        
    range = @completions.first.created_at.to_date..@time.to_date
    completion_index = 0
    nomination_index = 0
    
    logger.debug Paint["DATE RANGE: #{range.inspect}", :blue]
    
    range.step do |date|
      
      logger.debug Paint["DAY: #{date.inspect}", :blue]
      
      todays_completions = []
      until completion_index > @completions.length-1 || @completions[completion_index].created_at.to_date != date do
        todays_completions << @completions[completion_index]
        completion_index += 1
      end

      # todays_nomination = @user.nominations_dataset.first(nominated_for: date)
      until nomination_index > @nominations.length-1 || @nominations[nomination_index].nominated_for.to_date != date do
        todays_nomination = @nominations[nomination_index]
        nomination_index += 1
      end
      
      todays_completions.each do |completion|
        
        task_priority = todays_nomination&.priority(completion.task_id)
        @time_passed = last_date && (completion.created_at - last_date)
        
        msg = "TASK: #{completion.task_id}"
        msg += ", #{task_priority}" if task_priority
        logger.debug Paint[msg, :magenta]
        
        score_bonus = if task_priority.nil?
          BONUS_PER_CONSECUTIVE_TASK
        elsif task_priority == 0
          BONUS_PER_ESSENTIAL_TASK
        elsif task_priority > 0
          BONUS_PER_NICE_TO_HAVE_TASK
        end
        
        increment_combo if @time_passed
        
        @score += ((completion.value + score_bonus) * @combo).round(half: :down)
        
        logger.debug Paint["SCORE: #{@score}", :magenta]
        logger.debug Paint["COMBO: #{@combo}", :magenta]
        
        last_date = completion.created_at
      end
      
      if date != range.last
        @time_passed = (@time - last_date)
        @daily_tasks.reject {|t| todays_completions.any? {|c| c.task == t}}.each {apply_penalty}
        reset_combo if todays_completions.empty?
        
        essential_task_missed = todays_nomination&.essential_task && todays_completions.none? {|c| c.task == todays_nomination.essential_task}
        reset_combo if essential_task_missed
      end
      
      @combo = 1 if @combo < 1
      
    end
    
    logger.debug "\n"
    
    return result
  end
  
  private
  
  def result
    {score: @score, combo: @combo.round(half: :down)}
  end
  
  def increment_combo
    if @time_passed < ONE_DAY
      @combo += 1
      logger.debug Paint["COMBO: #{@combo}", :green]
    end
  end
  
  def reset_combo
    @combo = 1
    logger.debug Paint["RESET, COMBO: #{@combo}", :red]
  end
  
  def apply_penalty
    @combo *= PENALTY_PER_DAILY_TASK_MISSED
    logger.debug Paint["PENALTY, COMBO: #{@combo}", :yellow]
  end
  
end

