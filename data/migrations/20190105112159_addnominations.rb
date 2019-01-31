Sequel.migration do
  change do
    create_table(:nominations) do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      
      Date :nominated_for
      Integer :task_id
      Integer :user_id
      Integer :priority
    end
  end
end
