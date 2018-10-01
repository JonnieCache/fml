require 'app/models/task'

class Completion < Sequel::Model
  many_to_one :task
  
  dataset_module do
    def for_tag(tag)
      where(task_id: Task.where(tag_id: tag.id).select(Sequel[:tasks][:id]))
    end
  end
end