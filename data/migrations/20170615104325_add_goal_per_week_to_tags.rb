Sequel.migration do
  change do
    add_column :tags, :goal_per_week, Integer, default: 10
  end
end
