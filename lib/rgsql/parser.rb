module RgSql
  class Parser
    Int = Data.define(:value)
    Bool = Data.define(:value)

    Select = Data.define(:select_list, :table)
    SelectListItem = Data.define(:name, :value)
    CreateTable = Data.define(:table, :columns)
    Column = Data.define(:name, :type)
    DropTable = Data.define(:table, :if_exists)
    Insert = Data.define(:table, :rows)
    Reference = Data.define(:name)

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
            elsif statement.consume(/INSERT INTO/)
              parse_insert
            else
              raise ParsingError, "Unknown statement #{statement.rest}"
            end

      statement.consume(/;/)

      raise ParsingError, "Unexpected remaining statement: #{statement.rest}" unless statement.rest.empty?

      ast
    end

    private

    def parse_create_table
      table = statement.consume!(IDENTIFIER)
      statement.consume!(/\(/)
      columns = parse_list do
        parse_column_definition
      end
      statement.consume!(/\)/)
      CreateTable.new(table:, columns:)
    end

    def parse_column_definition
      name = statement.consume!(IDENTIFIER)
      type = statement.consume!(IDENTIFIER).upcase
      raise ParsingError, "Unknown type #{type}" unless TYPES.include?(type)

      Column.new(name:, type:)
    end

    def parse_drop_table
      if_exists = statement.consume(/IF EXISTS/) ? true : false
      table = statement.consume!(IDENTIFIER)
      DropTable.new(table:, if_exists:)
    end

    def parse_select
      select_list = parse_select_list
      table = statement.consume!(IDENTIFIER) if statement.consume(/FROM/)
      Select.new(select_list:, table:)
    end

    def parse_select_list
      return [] if statement.consume(/;/)

      parse_list do
        literal = parse_literal
        reference = statement.consume!(IDENTIFIER) if literal.nil?

        value = literal || Reference.new(reference)
        name = parse_select_list_item_name || reference || '???'
        SelectListItem.new(name:, value:)
      end
    end

    def parse_insert
      table = statement.consume!(IDENTIFIER)
      statement.consume!(/VALUES/)

      rows = parse_list do
        parse_insert_row
      end

      Insert.new(table:, rows:)
    end

    def parse_insert_row
      statement.consume!(/\(/)
      row = parse_list do
        parse_literal!
      end
      statement.consume!(/\)/)
      row
    end

    def parse_list(separator = /,/)
      values = []

      loop do
        values << yield
        break unless statement.consume(separator)
      end

      values
    end

    def parse_select_list_item_name
      statement.consume!(IDENTIFIER) if statement.consume(/AS/)
    end

    def parse_literal
      if statement.consume(/TRUE/)
        Bool.new(true)
      elsif statement.consume(/FALSE/)
        Bool.new(false)
      elsif (literal = statement.consume(INTEGER))
        Int.new(literal.to_i)
      end
    end

    def parse_literal!
      parse_literal || (raise ParsingError, "unexpected literal #{statement.rest}")
    end
  end
end
