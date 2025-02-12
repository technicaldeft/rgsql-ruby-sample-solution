module RgSql
  class Parser
    include Nodes

    TYPES = {
      'INTEGER' => Int,
      'BOOLEAN' => Bool
    }.freeze

    attr_reader :statement

    def initialize(sql)
      @statement = Statement.new(sql)
    end

    def to_ast
      ast = if statement.consume(:keyword, 'SELECT')
              parse_select
            elsif statement.consume(:keyword, 'CREATE')
              statement.consume!(:keyword, 'TABLE')
              parse_create_table
            elsif statement.consume(:keyword, 'DROP')
              statement.consume!(:keyword, 'TABLE')
              parse_drop_table
            elsif statement.consume(:keyword, 'INSERT')
              statement.consume!(:keyword, 'INTO')
              parse_insert
            else
              raise ParsingError, "Unexpected token #{statement.next_token}"
            end

      statement.consume(:symbol, ';')

      raise ParsingError, "Unexpected token: #{statement.next_token}" unless statement.empty?

      ast
    end

    private

    def parse_create_table
      table = statement.consume!(:identifier)
      statement.consume!(:symbol, '(')
      columns = parse_list do
        parse_column_definition
      end
      statement.consume!(:symbol, ')')
      CreateTable.new(table:, columns:)
    end

    def parse_column_definition
      name = statement.consume!(:identifier)
      type_name = statement.consume!(:keyword).upcase
      type = TYPES.fetch(type_name) { raise ParsingError, "Unknown type #{type_name}" }
      Column.new(name:, type:)
    end

    def parse_drop_table
      if_exists = statement.consume(:keyword, 'IF') ? true : false
      statement.consume!(:keyword, 'EXISTS') if if_exists
      table = statement.consume!(:identifier)
      DropTable.new(table:, if_exists:)
    end

    def parse_select
      select_list = parse_select_list
      table = statement.consume!(:identifier) if statement.consume(:keyword, 'FROM')
      where = statement.consume(:keyword, 'WHERE') ? ExpressionParser.parse(statement) : Bool.new(true)
      order = parse_select_order
      Select.new(select_list:, table:, where:, order:)
    end

    def parse_select_list
      return [] if statement.consume(:symbol, ';')

      parse_list do
        expression = ExpressionParser.parse(statement)

        reference_name = expression.is_a?(Reference) && expression.name
        name = parse_select_list_item_name || reference_name || '???'
        SelectListItem.new(name:, expression:)
      end
    end

    def parse_insert
      table = statement.consume!(:identifier)
      statement.consume!(:keyword, 'VALUES')

      rows = parse_list do
        parse_insert_row
      end

      Insert.new(table:, rows:)
    end

    def parse_insert_row
      statement.consume!(:symbol, '(')
      row = parse_list do
        ExpressionParser.parse(statement)
      end
      statement.consume!(:symbol, ')')
      row
    end

    def parse_list(separator = ',')
      values = []

      loop do
        values << yield
        break unless statement.consume(:symbol, separator)
      end

      values
    end

    def parse_select_order
      return unless statement.consume(:keyword, 'ORDER')

      statement.consume!(:keyword, 'BY')
      expression = ExpressionParser.parse(statement)
      direction = statement.consume(:keyword, 'ASC') || statement.consume(:keyword, 'DESC') || 'ASC'
      Order.new(expression, direction == 'ASC')
    end

    def parse_select_list_item_name
      statement.consume!(:identifier) if statement.consume(:keyword, 'AS')
    end
  end
end
