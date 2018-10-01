class SquaresCalculator
  def initialize(points:)
    @points = points
    @result = []
  end
  
  def calculate!
    _calculate!(@points)
    @result
  end
  
  def _calculate!(score)
    while score > 0
      l = level(score)
      result[l] ||= 0
      result[l] += 1
    end
    
    @result
  end
  
  private
  
  def biggest_power_of_ten(n)
    i = 0
    i += 1 until 10 ** (i+1) > n
    
    10 ** i
  end
  
  def level(n)
    level = 0
    level += 1 until 10 ** (level+1) > n
    
    level 
  end
  
  # def _calculate!(score, power = 1)
  #   limit     = 10 ** power
  #   nextlimit = 10 ** (power+1)
    
  #   binding.pry; 
  #   score = _calculate!(score, power+1) unless nextlimit > score
  #   @result << limit
  #   score -= limit
  #   score
  # end
end
