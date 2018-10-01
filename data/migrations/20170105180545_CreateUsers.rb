Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      
      String :name
      String :email
      String :password
      
      column :task_order, 'integer[]', default: Sequel.pg_array([], :integer)
    end
  end
end
