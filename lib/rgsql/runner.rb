module RgSql
  class Runner
    include Nodes

    attr_reader :ast, :database

    def initialize(database, ast)
      @database = database
      @ast = ast
    end

    def execute
      case ast
      when Select
        execute_select(ast)
      when CreateTable
        execute_create_table(ast)
      when DropTable
        execute_drop_table(ast)
      when Insert
        execute_insert(ast)
      else
        raise "unexpected node #{ast.class}"
      end
    end

    private

    def execute_insert(ast)
      table = database.get_table(ast.table)
      table.validate_insert(ast.rows)
      table.insert(ast.rows)
      { status: 'ok' }
    end

    def execute_create_table(ast)
      columns = {}
      ast.columns.map do |column|
        raise ValidationError, "duplicate column name #{column.name}" if columns.key?(column.name)

        columns[column.name] = column.type
      end
      database.create_table(ast.table, columns)
      { status: 'ok' }
    end

    def execute_drop_table(ast)
      database.drop_table(ast.table, ast.if_exists)
      { status: 'ok' }
    end

    def execute_select(select)
      runner = SelectRunner.new(database, select)
      runner.validate
      runner.run
    end
  end
end
