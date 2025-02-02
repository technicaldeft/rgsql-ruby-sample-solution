module RgSql
  class Types
    def self.all_match?(expected_types, actual_types)
      return false unless expected_types.size == actual_types.size

      expected_types.zip(actual_types).all? do |expected_type, actual_type|
        match?(expected_type, actual_type)
      end
    end

    def self.match?(expected_type, actual_type)
      actual_type == Nodes::Null || actual_type == expected_type
    end
  end
end
