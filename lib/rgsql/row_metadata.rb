module RgSql
  class RowMetadata
    include Nodes

    TableColumn = Data.define(:full_name, :type, :table_name, :column_name)
    SelectListItem = Data.define(:name, :type)

    def self.empty
      new([])
    end

    def self.from_table(table)
      metadata = new([])
      metadata.add_table(table)
      metadata
    end

    def initialize(columns)
      @columns = columns
    end

    def add_select_list_item(name, type)
      @columns << SelectListItem.new(name, type)
    end

    def add_table(table, table_name = table.name)
      if @columns.any? { |column| column.is_a?(TableColumn) && column.table_name == table_name }
        raise ValidationError, "duplicate table name #{table_name}"
      end

      new_columns = table.column_definitions.map do |name, type|
        full_name = "#{table_name}.#{name}"
        TableColumn.new(full_name, type, table_name, name)
      end
      @columns += new_columns
    end

    def get_reference(row, reference)
      offset = reference_offset(reference)
      row[offset]
    end

    def get_select_list(row)
      values = []

      @columns.each.with_index do |column, index|
        values << row[index] if column.is_a?(SelectListItem)
      end

      values
    end

    def resolve_reference(reference)
      name = reference.name.downcase
      column = resolved_qualified(name) || resolve_unqualified(name)
      raise ValidationError, "unknown column #{name}" unless column

      reference.resolved = column
    end

    def resolve_order_by_reference(reference)
      name = reference.name.downcase
      reference.resolved = resolve_select_list_item(name) || resolve_reference(reference)
    end

    def row_for_unmatched_right_join(table_name)
      first_right_row_index = @columns.find_index do |column|
        column.is_a?(TableColumn) && column.table_name == table_name
      end
      Array.new(first_right_row_index) { Nodes::Null.new }
    end

    private

    def reference_offset(reference)
      @columns.find_index { |column| column == reference.resolved }
    end

    def resolve_select_list_item(name)
      @columns.find { |column| column.is_a?(SelectListItem) && column.name == name }
    end

    def resolve_unqualified(name)
      matching_columns = @columns.select { |column| column.is_a?(TableColumn) && column.column_name == name }
      if matching_columns.size == 0
        nil
      elsif matching_columns.size > 1
        raise ValidationError, "ambiguous column name #{name}"
      else
        matching_columns.first
      end
    end

    def resolved_qualified(name)
      @columns.find { |column| column.is_a?(TableColumn) && column.full_name == name }
    end
  end
end
