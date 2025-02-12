module RgSql
  class SelectRunner
    include Nodes

    attr_reader :database, :select, :metadata

    def initialize(database, select)
      @database = database
      @select = select
      @table = if select.table
                 database.get_table(select.table)
               else
                 Table.new(nil, {}, [[]])
               end

      @metadata = RowMetadata.new(@table)
    end

    def validate
      unless Types.match?(Bool, Expression.type(select.where, metadata))
        raise ValidationError, 'where clause must evaluate to a boolean'
      end

      select.select_list.each do |item|
        type = Expression.type(item.expression, metadata)
        metadata.add_select_list_item(item.name, type)
      end

      Expression.type(select.order.expression, metadata) if select.order
    end

    def run
      rows = @table.rows

      rows = rows.select do |row|
        evaluate(select.where, row) == Bool.new(true)
      end

      rows.each do |row|
        select.select_list.each do |item|
          result = evaluate(item.expression, row)
          row << result
        end
      end

      if select.order
        rows = rows.sort do |row_a, row_b|
          comparison_value(row_a, row_b)
        end
      end

      output_rows = rows.map { |row| metadata.get_select_list(row).map(&:value) }

      column_names = select.select_list.map(&:name)
      { status: 'ok', rows: output_rows, column_names: }
    end

    private

    def comparison_value(row_a, row_b)
      value_a = evaluate(select.order.expression, row_a)
      value_b = evaluate(select.order.expression, row_b)

      if select.order.ascending
        value_a <=> value_b
      else
        value_b <=> value_a
      end
    end

    def evaluate(expression, row)
      Expression.evaluate(expression, row, metadata)
    end
  end
end
