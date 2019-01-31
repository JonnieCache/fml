Sequel.migration do
  change do
    add_column :tasks, :last_nominated_at, Date
  end
end
