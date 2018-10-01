class NeedsCalculator
  def initialize(tags, user:, time: Time.now)
    @tags = tags
    @time = time
    @user = user
  end
  
  def calculate!
    @tags.each do |tag|
      total = Completion.for_tag(tag).where(Sequel.lit("created_at >= ?", @time.to_date - 7)).sum(:value).to_f
      tag.values[:need] = [total / tag.goal_per_week, 1.0].min
    end
  end
  
end
