require 'app/calculators/needs_calculator'
require 'app/calculators/combo_calculator'
require 'lib/core_ext/to_hash_recursive'
require 'lib/core_ext/to_id_hash'

class StatePresenter
  def initialize(user, tasks: nil, completions: nil, nomination: nil, tags: nil, time: Time.now)
    raise ArgumentError, 'User required' unless user.is_a? User
    @user = user
    
    @tasks = Array(tasks || @user.tasks_ordered.where(state: 'incomplete'))
    @completions = Array(completions || @user.completions_dataset.order(:created_at))
    @nomination = nomination || @user.nominations_dataset.where(nominated_for: time.to_date+1).first
    @tags = Array(tags || @user.tags)
    
    @time = time
  end
  
  def render
    state = {
      tasks: @tasks,
      completions: @completions.to_id_hash,
      nomination: @nomination || {},
      tags: @tags,
      user: @user
    }
    NeedsCalculator.new(state[:tags], user: @user, time: @time).calculate!
    state[:tags] = state[:tags].to_id_hash
    
    state.merge! ComboCalculator.new(@user, completions: @completions, nominations: @nominations, time: @time).calculate!
    
    state.to_hash_recursive
  end
  
  def to_json
    render.to_json
  end
end
