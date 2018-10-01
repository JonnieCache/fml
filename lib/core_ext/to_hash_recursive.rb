class Hash
  def to_hash_recursive
    result = self.to_hash

    result.each do |key, value|
      case value
      when Hash, Array
        result[key] = value.to_hash_recursive
      when Sequel::Model
        result[key] = value.to_hash
      end
    end

    result
  end
end

class Array
  def to_hash_recursive
    result = self

    result.each_with_index do |value, index|
      case value
      when Hash, Array
        result[index] = value.to_hash_recursive
      when Sequel::Model
        result[index] = value.to_hash
      end
    end

    result
  end
end
