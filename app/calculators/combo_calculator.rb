require 'lib/fml_logger'

class ComboCalculator
  include FMLLogger
  ONE_DAY = 86400
  BONUS_PER_CONSECUTIVE_TASK = 1
  PENALTY_PER_DAILY_TASK_MISSED = 0.5
  
  def initialize(user, completions: nil, time: Time.now)
    @user = user
    @completions = Array(completions || @user.completions_dataset.order(:created_at))
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
    index = 0
    logger.debug Paint["DATE RANGE: #{range.inspect}", :blue]
    range.step do |date|
      logger.debug Paint["DAY: #{date.inspect}", :blue]
      todays_c = []
      until index > @completions.length-1 || @completions[index].created_at.to_date != date do
        todays_c << @completions[index]
        index += 1
      end
      
      todays_c.each_with_index do |completion, index|
        @time_passed = last_date && (completion.created_at - last_date)
        
        increment_combo if @time_passed
        
        @score += (completion.value * @combo).round(half: :down)
        logger.debug Paint["SCORE: #{@score}", :magenta]
        
        last_date = completion.created_at
      end
      
      if date != range.last
        @time_passed = (@time - last_date)
        @daily_tasks.reject {|t| todays_c.any? {|c| c.task == t}}.each {apply_penalty}
        reset_combo if todays_c.empty?
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
  
  def mutate_combo
    increment_combo
    # reset_combo
  end
  
  def increment_combo
    if @time_passed < ONE_DAY
      @combo += BONUS_PER_CONSECUTIVE_TASK
      logger.debug Paint["BONUS, COMBO: #{@combo}", :green]
    end
  end
  
  def reset_combo
    # if @time_passed >= ONE_DAY
    @combo = 1
    logger.debug Paint["RESET, COMBO: #{@combo}", :red]
    # end
  end
  
  def apply_penalty
    @combo *= PENALTY_PER_DAILY_TASK_MISSED
    logger.debug Paint["PENALTY, COMBO: #{@combo}", :yellow]
  end
  
end

