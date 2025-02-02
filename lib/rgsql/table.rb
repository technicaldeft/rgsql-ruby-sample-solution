module RgSql
  class Table
    attr_reader :name, :column_definitions, :rows

    def initialize(name, column_definitions, rows = [])
      @name = name
      @column_definitions = column_definitions
      @rows = rows
    end

    def insert(new_rows)
      evaluated_rows = new_rows.map do |row|
        row.map { |expression| Expression.evaluate(expression) }
      end

      @rows += evaluated_rows
    end

    def column_index(name)
      column_names.index(name)
    end

    def get_reference(row, name)
      index = column_index(name)

      if index
        row[index]
      else
        raise("column with name #{name} not found")
      end
    end

    def column_type(name)
      column_definitions.fetch(name) { raise ValidationError, "unknown column #{name}" }
    end

    def validate_insert(new_rows)
      new_rows.each do |row|
        row.each_with_index do |expression, index|
          column = column_name(index)
          expected_type = column_type(column)
          actual_type = Expression.type(expression, self)

          if expected_type != actual_type
            raise ValidationError, "Invalid type for #{column}, expected #{expected_type} but was #{actual_type}"
          end
        end
      end
    end

    private

    def column_name(index)
      column_names[index]
    end

    def column_names
      column_definitions.keys
    end
  end
end
