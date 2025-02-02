module RgSql
  class Types
    def self.match?(expected_type, actual_type)
      actual_type == Nodes::Null || actual_type == expected_type
    end
  end
end
