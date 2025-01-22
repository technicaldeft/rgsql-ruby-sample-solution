module RgSql
  class Runner
    attr_reader :ast, :database

    def initialize(database, ast)
      @database = database
      @ast = ast
    end

    def execute
      case ast
      when Parser::Select
        execute_select(ast)
      when Parser::CreateTable
        execute_create_table(ast)
      when Parser::DropTable
        execute_drop_table(ast)
      else
        raise "unexpected node #{ast.class}"
      end
    end

    private

    def execute_create_table(ast)
      database.create_table(ast.table, ast.columns)
      { status: 'ok' }
    end

    def execute_drop_table(ast)
      database.drop_table(ast.table, ast.if_exists)
      { status: 'ok' }
    end

    def execute_select(ast)
      row = ast.select_list.map { |item| item.value.value }
      column_names = ast.select_list.map(&:name)
      { status: 'ok', rows: [row], column_names: }
    end
  end
end
