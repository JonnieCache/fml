Sequel.migration do
  change do
    add_column :tasks, :daily, TrueClass, default: false
  end
end
