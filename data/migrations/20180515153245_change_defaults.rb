Sequel.migration do
  change do
    set_column_default :tags, :show_meter, true
    set_column_default :tasks, :recurring, true
  end
end
