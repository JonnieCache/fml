Sequel.migration do
  change do
    add_column :tasks, :tag_id, Integer
  end
end
