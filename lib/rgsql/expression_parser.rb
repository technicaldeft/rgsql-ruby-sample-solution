module RgSql
  class ExpressionParser
    include Nodes
    PREFIX_OPERATORS = ['-', 'NOT'].freeze

    attr_reader :statement

    def self.parse(statement)
      new(statement).parse
    end

    def initialize(statement)
      @statement = statement
    end

    def parse
      term = parse_term
      if (operator = statement.consume(:operator))
        Operator.new(operator, [term, parse_term])
      else
        term
      end
    end

    def parse_term
      if (identifier = statement.consume(:identifier))
        Reference.new(identifier)
      elsif (boolean = statement.consume(:boolean))
        Bool.new(boolean == 'TRUE')
      elsif (integer = statement.consume(:integer))
        Int.new(integer)
      elsif (operator = statement.consume(:operator))
        parse_prefix_operator(operator)
      elsif statement.consume(:symbol, '(')
        term = parse
        statement.consume!(:symbol, ')')
        term
      else
        raise ParsingError, "unexpected token in expression `#{statement.next_token}`"
      end
    end

    private

    def parse_prefix_operator(operator)
      raise ParsingError, "expected a prefix operator but found #{operator}" unless PREFIX_OPERATORS.include?(operator)

      Operator.new(operator, [parse_term])
    end
  end
end
