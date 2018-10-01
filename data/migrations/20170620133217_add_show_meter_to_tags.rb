Sequel.migration do
  change do
    add_column :tags, :show_meter, TrueClass, default: false
  end
end
