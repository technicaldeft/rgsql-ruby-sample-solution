module RgSql
  class Parser
    Int = Data.define(:value)
    Bool = Data.define(:value)

    Select = Data.define(:select_list)
    SelectListItem = Data.define(:name, :value)
    CreateTable = Data.define(:table, :columns)
    Column = Data.define(:name, :type)
    DropTable = Data.define(:table, :if_exists)

    IDENTIFIER = /[a-z_][a-z\d_]*/i
    INTEGER = /-?\d+/
    TYPES = %w[INTEGER BOOLEAN].freeze

    attr_reader :statement

    def initialize(sql)
      @statement = Statement.new(sql)
    end

    def to_ast
      ast = if statement.consume(/SELECT/)
              parse_select
            elsif statement.consume(/CREATE TABLE/)
              parse_create_table
            elsif statement.consume(/DROP TABLE/)
              parse_drop_table
            else
              raise ParsingError, "Unknown statement #{statement.rest}"
            end

      statement.consume(/;/)

      raise ParsingError, "Unexpected remaining statement: #{statement.rest}" unless statement.rest.empty?

      ast
    end

    private

    def parse_create_table
      table = statement.consume(IDENTIFIER)
      statement.consume(/\(/)
      columns = []
      loop do
        columns << parse_column_definition
        break unless statement.consume(/,/)
      end
      statement.consume(/\)/)
      CreateTable.new(table:, columns:)
    end

    def parse_column_definition
      name = statement.consume(IDENTIFIER)
      raise ParsingError, 'Expected column name' unless name

      type = statement.consume(IDENTIFIER).upcase
      raise ParsingError, "Unknown type #{type}" unless TYPES.include?(type)

      Column.new(name:, type:)
    end

    def parse_drop_table
      if_exists = statement.consume(/IF EXISTS/) ? true : false
      table = statement.consume(IDENTIFIER)
      DropTable.new(table:, if_exists:)
    end

    def parse_select
      Select.new(select_list: parse_select_list)
    end

    def parse_select_list
      return [] if statement.consume(/;/)

      values = []

      loop do
        value = parse_literal
        name = parse_select_list_item_name
        values << SelectListItem.new(name:, value:)
        break unless statement.consume(/,/)
      end

      values
    end

    def parse_select_list_item_name
      if statement.consume(/AS/)
        statement.consume(IDENTIFIER)
      else
        '???'
      end
    end

    def parse_literal
      if statement.consume(/TRUE/)
        Bool.new(true)
      elsif statement.consume(/FALSE/)
        Bool.new(false)
      elsif (literal = statement.consume(INTEGER))
        Int.new(literal.to_i)
      else
        raise ParsingError, "unexpected literal #{statement.rest}"
      end
    end
  end
end
