module RgSql
  class RowMetadata
    include Nodes

    TableColumn = Data.define(:full_name, :type, :table_name, :column_name)
    SelectListItem = Data.define(:name, :type)

    def self.empty
      new(Table.empty)
    end

    def initialize(table)
      @columns = table.column_definitions.map do |name, type|
        full_name = "#{table.name}.#{name}"
        TableColumn.new(full_name, type, table.name, name)
      end
    end

    def add_select_list_item(name, type)
      @columns << SelectListItem.new(name, type)
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

    private

    def reference_offset(reference)
      @columns.find_index { |column| column == reference.resolved }
    end

    def resolve_select_list_item(name)
      @columns.find { |column| column.is_a?(SelectListItem) && column.name == name }
    end

    def resolve_unqualified(name)
      @columns.find { |column| column.is_a?(TableColumn) && column.column_name == name }
    end

    def resolved_qualified(name)
      @columns.find { |column| column.is_a?(TableColumn) && column.full_name == name }
    end
  end
end
