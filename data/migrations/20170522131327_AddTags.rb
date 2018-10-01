Sequel.migration do
  change do
    create_table :tags do
      primary_key :id
      DateTime :created_at
      DateTime :updated_at
      
      String :name
    end
    
    create_table :taggings do
      Integer :tag_id
      Integer :taggable_id
      String :taggable_type
      
      DateTime :created_at
      DateTime :updated_at
      
      index [:taggable_id, :tag_id, :taggable_type], :unique => true
    end
  end
end
