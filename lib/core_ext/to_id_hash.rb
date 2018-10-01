class Array
  def to_id_hash
    each_with_object({}) { |model, acc| acc[model.id] = model }
  end
end