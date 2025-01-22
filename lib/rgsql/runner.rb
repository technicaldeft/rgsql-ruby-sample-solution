module RgSql
  class Runner
    attr_reader :ast

    def initialize(ast)
      @ast = ast
    end

    def execute
      case ast
      when Parser::Select
        execute_select(ast)
      else
        raise "unexpected node #{ast.class}"
      end
    end

    private

    def execute_select(ast)
      values = ast.select_list.map { |item| item.value.value }
      names = ast.select_list.map(&:name)
      [values, names]
    end
  end
end
