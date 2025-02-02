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
        parse_identifier(identifier)
      elsif (boolean = statement.consume(:boolean))
        Bool.new(boolean == 'TRUE')
      elsif (integer = statement.consume(:integer))
        Int.new(integer)
      elsif (operator = statement.consume(:null))
        Null.new
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

    def parse_identifier(identifier)
      if statement.consume(:symbol, '(')
        arguments = parse_function_arguments
        statement.consume!(:symbol, ')')
        Function.new(identifier, arguments)
      else
        Reference.new(identifier)
      end
    end

    def parse_function_arguments
      arguments = []
      loop do
        arguments << parse
        break unless statement.consume(:symbol, ',')
      end
      arguments
    end

    def parse_prefix_operator(operator)
      raise ParsingError, "expected a prefix operator but found #{operator}" unless PREFIX_OPERATORS.include?(operator)

      Operator.new(operator, [parse_term])
    end
  end
end
