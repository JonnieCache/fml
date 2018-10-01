Sequel.migration do
  change do
    add_column :completions, :user_id, Integer
  end
end
