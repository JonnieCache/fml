Sequel.migration do
  up do
    add_column :nominations, :essential_task_id, Integer
    add_column :nominations, :nice_task_1_id, Integer
    add_column :nominations, :nice_task_2_id, Integer
    drop_column :nominations, :priority
    drop_column :nominations, :task_id
  end
  
  down do
    drop_column :nominations, :essential_task_id
    drop_column :nominations, :nice_task_1_id
    drop_column :nominations, :nice_task_2_id
    add_column :nominations, :priority, Integer
    add_column :nominations, :task_id, Integer
  end
end
