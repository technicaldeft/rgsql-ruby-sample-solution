module RgSql
  class Table
    attr_reader :name, :column_definitions, :rows

    def initialize(name, column_definitions, rows = [])
      @name = name
      @column_definitions = column_definitions
      @rows = rows
    end

    def insert(new_rows)
      @rows.concat(new_rows)
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

    private

    def column_names
      column_definitions.keys
    end
  end
end
