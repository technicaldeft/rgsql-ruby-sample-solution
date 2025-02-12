module RgSql
  class RowMetadata
    def initialize(table)
      @table = table
      @select_list_offset = table.column_definitions.size
      @select_list = {}
    end

    def reference_type(name)
      type = @table.column_type(name)
      type ||= @select_list[name]
      type || raise(ValidationError, "unknown column #{name}")
    end

    def add_select_list_item(name, type)
      @select_list[name] = type
    end

    def get_reference(row, name)
      if (column_index = column_index(name))
        row[column_index]
      elsif (item_index = select_list_item_index(name))
        row[@select_list_offset + item_index]
      else
        raise "item with name #{name} not found after type check"
      end
    end

    def get_select_list(row)
      row[@select_list_offset..]
    end

    private

    def column_index(name)
      @table.column_index(name)
    end

    def select_list_item_index(name)
      @select_list.keys.index(name)
    end
  end
end
