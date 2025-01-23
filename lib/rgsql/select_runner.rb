module RgSql
  class SelectRunner
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
          evaluate(item, row)
        end
      end

      column_names = select.select_list.map(&:name)
      { status: 'ok', rows:, column_names: }
    end

    private

    def evaluate(item, row)
      case item.value
      when Parser::Reference
        index = @table.column_index(item.value.name)
        row[index].value
      else
        item.value.value
      end
    end
  end
end
