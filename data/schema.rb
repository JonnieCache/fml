Sequel.migration do
  change do
    create_table(:account_statuses, :ignore_index_errors=>true) do
      Integer :id, :null=>false
      String :name, :text=>true, :null=>false
      
      primary_key [:id]
      
      index [:name], :name=>:account_statuses_name_key, :unique=>true
    end
    
    create_table(:completions) do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      Integer :task_id
      Integer :value
      Integer :user_id
    end
    
    create_table(:schema_migrations) do
      String :filename, :text=>true, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:tags, :ignore_index_errors=>true) do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      String :name, :text=>true
      Integer :user_id
      String :color, :text=>true
      Integer :goal_per_week, :default=>10
      TrueClass :show_meter, :default=>true
      
      index [:user_id]
    end
    
    create_table(:tasks) do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      DateTime :last_completed_at
      Integer :user_id
      String :name, :text=>true
      String :description, :text=>true
      String :state, :text=>true
      TrueClass :recurring, :default=>true
      Integer :value
      Integer :tag_id
      TrueClass :daily, :default=>false
    end
    
    create_table(:users) do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      String :name, :text=>true
      String :email, :null=>false
      String :password_hash, :text=>true
      String :task_order
      foreign_key :status_id, :account_statuses, :default=>1, :null=>false, :key=>[:id]
    end
    
    create_table(:account_password_reset_keys) do
      foreign_key :id, :users, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      DateTime :deadline, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_remember_keys) do
      foreign_key :id, :users, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      DateTime :deadline, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:id]
    end
  end
end
