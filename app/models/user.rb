require 'app/models/task'
require 'app/models/completion'
require 'app/models/nomination'

class User < Sequel::Model
  one_to_many :tasks
  one_to_many :completions
  one_to_many :nominations
  one_to_many :tags
  attr_accessor :password
  
  def tasks_ordered
    tasks_dataset.order_by_ids(task_order)
  end
  
  def before_save  
    self.values[:password_hash] = password_hash(password) if password
  end
  
  if ENV['RACK_ENV'] == 'test'
    def password_hash_cost
      BCrypt::Engine::MIN_COST
    end
  else
    def password_hash_cost
      BCrypt::Engine::DEFAULT_COST
    end
  end

  def password_hash(password)
    BCrypt::Password.create(password, cost: self.password_hash_cost)
  end
end
