module RgSql
  class Parser
    Int = Data.define(:value)
    Bool = Data.define(:value)

    Select = Data.define(:select_list)

    INTEGER = /-?\d+/

    attr_reader :statement

    def initialize(sql)
      @statement = Statement.new(sql)
    end

    def to_ast
      ast = if statement.consume(/SELECT/)
              parse_select
            else
              raise ParsingError, "Unknown statement #{statement.rest}"
            end

      statement.consume(/;/)

      raise ParsingError, "Unexpected remaining statement: #{statement.rest}" unless statement.rest.empty?

      ast
    end

    private

    def parse_select
      Select.new(select_list: parse_select_list)
    end

    def parse_select_list
      return [] if statement.consume(/;/)

      values = []

      loop do
        values << parse_literal
        break unless statement.consume(/,/)
      end

      values
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
