require 'active_support/core_ext/string/inflections'

class Tag < Sequel::Model
  one_to_many :tasks
  many_to_one :user
  plugin :validation_helpers
  COLOR_GEN = ColorGenerator.new saturation: 0.8, lightness: 0.75
  
  def before_create
    super
    
    set_color
  end
  
  def validate
    validates_presence :user_id
    # length name 15
  end
  
  def to_param
    self.name.parameterize
  end
  
  def set_color
    self.color = COLOR_GEN.create_hex
  end
  
  def need
    values[:need]
  end
end
