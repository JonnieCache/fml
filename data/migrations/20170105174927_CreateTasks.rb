Sequel.migration do
  change do
    create_table :tasks do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      DateTime :last_completed_at
      
      Integer :user_id
      
      String :name
      String :description
      String :state
      TrueClass :recurring, default: false
      Integer :value
    end
  end
end
