module RgSql
  class Expression
    class << self
      include Nodes

      def type(expression, table)
        case expression
        when Operator
          type_operator(expression, type_list(expression.operands, table))
        when Function
          type_function(expression, type_list(expression.arguments, table))
        when Int, Bool
          expression.class
        when Reference
          table.column_type(expression.name)
        end
      end

      def evaluate(expression, row = [], table = nil)
        case expression
        when Operator
          operands = evaluate_list(expression.operands, row, table)
          Callable.find_operator(expression.operator).call(operands)
        when Function
          arguments = evaluate_list(expression.arguments, row, table)
          Callable.find_function(expression.name).call(arguments)
        when Reference
          table.get_reference(row, expression.name)
        when Int, Bool
          expression
        else
          raise "unknown expression #{expression.inspect} of type #{expression.class}"
        end
      end

      private

      def type_operator(expression, operand_types)
        operator = Callable.find_operator(expression.operator)
        unless operator.accepts_types?(operand_types)
          raise(ValidationError, "Operator #{expression.operator} does not accept types #{operand_types}")
        end

        operator.output_type
      end

      def type_function(expression, argument_types)
        function = Callable.find_function(expression.name)
        unless function.accepts_types?(argument_types)
          raise(ValidationError, "Function #{expression.name} does not accept types #{argument_types}")
        end

        function.output_type
      end

      def evaluate_list(expressions, row, table)
        expressions.map { |expression| evaluate(expression, row, table) }
      end

      def type_list(expressions, table)
        expressions.map { |expression| type(expression, table) }
      end
    end
  end
end
