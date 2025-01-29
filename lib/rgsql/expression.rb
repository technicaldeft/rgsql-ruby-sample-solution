module RgSql
  class Expression
    class << self
      include Nodes

      def evaluate(expression, row = [], table = nil)
        case expression
        when Operator
          evaluate_operator(expression.operator, evaluate_list(expression.operands, row, table))
        when Function
          evaluate_function(expression.name, evaluate_list(expression.arguments, row, table))
        when Reference
          table.get_reference(row, expression.name)
        when Int, Bool
          expression
        else
          raise "unknown expression #{expression.inspect} of type #{expression.class}"
        end
      end

      private

      def evaluate_list(expressions, row, table)
        expressions.map { |expression| evaluate(expression, row, table) }
      end

      def evaluate_function(name, arguments)
        arg1 = arguments[0]
        arg2 = arguments[1]

        case name
        when 'ABS'
          Int.new(arg1.value.abs)
        when 'MOD'
          Int.new(arg1.value % arg2.value)
        else
          raise "unknown function #{name}"
        end
      end

      def evaluate_operator(operator, operands)
        op1 = operands[0]
        op2 = operands[1]

        case operator
        when '+'
          Int.new(op1.value + op2.value)
        when '-'
          if operands.length == 1
            Int.new(-op1.value)
          else
            Int.new(op1.value - op2.value)
          end
        when '*'
          Int.new(op1.value * op2.value)
        when '/'
          Int.new(op1.value / op2.value)
        when 'NOT'
          Bool.new(!op1.value)
        when 'AND'
          Bool.new(op1.value && op2.value)
        when 'OR'
          Bool.new(op1.value || op2.value)
        when '<'
          Bool.new(to_integer(op1) < to_integer(op2))
        when '>'
          Bool.new(to_integer(op1) > to_integer(op2))
        when '>='
          Bool.new(to_integer(op1) >= to_integer(op2))
        when '<='
          Bool.new(to_integer(op1) <= to_integer(op2))
        when '='
          Bool.new(op1.value == op2.value)
        when '<>'
          Bool.new(op1.value != op2.value)
        else
          raise "unknown operator #{operator}"
        end
      end

      def to_integer(argument)
        case argument
        when Int
          argument.value
        when Bool
          argument.value ? 1 : 0
        else
          raise "unexpected argument type #{argument.class}"
        end
      end
    end
  end
end
