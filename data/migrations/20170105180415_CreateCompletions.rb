Sequel.migration do
  change do
    create_table :completions do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      
      Integer :task_id
      Integer :value
    end
  end
end
