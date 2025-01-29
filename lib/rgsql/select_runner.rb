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

    def run
      rows = @table.rows.map do |row|
        select.select_list.map do |item|
          evaluate(item.expression, row)
        end
      end

      column_names = select.select_list.map(&:name)
      { status: 'ok', rows:, column_names: }
    end

    private

    def evaluate(expression, row)
      Expression.evaluate(expression, row, @table).value
    end
  end
end
