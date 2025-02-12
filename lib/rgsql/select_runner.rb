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

      unless Types.match?(Int, Expression.type(select.limit))
        raise ValidationError, 'limit must evaluate to the type integer'
      end

      unless Types.match?(Int, Expression.type(select.offset))
        raise ValidationError, 'offset must evaluate to the type integer'
      end
    end

    def run
      load_rows
      filter_rows
      evaluate_select_list
      sort_rows
      apply_offset
      apply_limit

      {
        status: 'ok',
        rows: output_rows,
        column_names: select.select_list.map(&:name)
      }
    end

    private

    def load_rows
      @rows = @table.rows
    end

    def filter_rows
      @rows = @rows.select do |row|
        evaluate(select.where, row) == Bool.new(true)
      end
    end

    def evaluate_select_list
      @rows.each do |row|
        select.select_list.each do |item|
          row << evaluate(item.expression, row)
        end
      end
    end

    def sort_rows
      return unless select.order

      @rows = @rows.sort do |row_a, row_b|
        comparison_value(row_a, row_b)
      end
    end

    def apply_offset
      evaluated_offset = Expression.evaluate(select.offset)
      return if evaluated_offset.is_a? Null

      @rows = @rows.drop(evaluated_offset.value)
    end

    def apply_limit
      evaluated_limit = Expression.evaluate(select.limit)
      return if evaluated_limit.is_a? Null

      @rows = @rows.first(evaluated_limit.value)
    end

    def output_rows
      @rows.map do |row|
        metadata.get_select_list(row).map(&:value)
      end
    end

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
