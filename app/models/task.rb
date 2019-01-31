require 'app/models/user'
require 'app/models/completion'
require 'app/models/tag'
require 'app/models/nomination'

class Task < Sequel::Model
  one_to_many :completions
  one_to_many :nominations
  many_to_one :user
  many_to_one :tag
  
  def before_save
    super
    
    if tag_id.is_a? String
      values[:tag_id] = Tag.create(name: tag_id, user_id: self.user_id).id
    end
    
    true
  end
  
  state_machine initial: :incomplete do
    event(:complete) {transition          :incomplete => :complete  }
    event(:reopen)   {transition [:complete, :closed] => :incomplete}
    event(:close)    {transition          :incomplete => :closed    }
  end
  
  dataset_module do
    
    def order_by_ids(ids)
      ids ||= Array(ids)
      
      left_join(Sequel.lit("unnest(?) WITH ORDINALITY AS ordering(id, ord) USING (id)", Sequel.pg_array(ids, :integer))).
      order(Sequel[:ordering][:ord]).
      select_all(:tasks)
    end
  end
  
  def finished?
    closed? || complete?
  end
  
  def to_hash
    values.except(:user_id)
  end
  
  def to_s
    "#<Task #{id}: #{name}>"
  end

end
