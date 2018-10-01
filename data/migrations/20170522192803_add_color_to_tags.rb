Sequel.migration do
  change do
    add_column :tags, :color, String
  end
end
