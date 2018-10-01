Sequel.migration do
  change do
    DB[:tasks].each {|task| tid = DB[:taggings].first(taggable_id: task[:id])[:tag_id]; DB[:tasks].update(tag_id: tid) }
    
    drop_table :taggings
  end
end
