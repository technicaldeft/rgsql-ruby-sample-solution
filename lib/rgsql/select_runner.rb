module RgSql
  class SelectRunner
    include Nodes

    attr_reader :database, :select

    def initialize(database, select)
      @database = database
      @select = select
      @table = if select.table
                 database.get_table(select.table)
               else
                 Table.new(nil, {}, [[]])
               end
    end

    def validate
      unless Types.match?(Bool, Expression.type(select.where, @table))
        raise ValidationError, 'where clause must evaluate to a boolean'
      end

      select.select_list.each do |item|
        Expression.type(item.expression, @table)
      end
    end

    def run
      rows = @table.rows.select do |row|
        evaluate(select.where, row) == Bool.new(true)
      end

      rows = rows.map do |row|
        select.select_list.map do |item|
          evaluate(item.expression, row).value
        end
      end

      column_names = select.select_list.map(&:name)
      { status: 'ok', rows:, column_names: }
    end

    private

    def evaluate(expression, row)
      Expression.evaluate(expression, row, @table)
    end
  end
end
