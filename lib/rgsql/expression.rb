module RgSql
  class Expression
    class << self
      include Nodes

      def type(expression, table)
        case expression
        when Operator
          type_operator(expression.operator, type_list(expression.operands, table))
        when Function
          type_function(expression.name, type_list(expression.arguments, table))
        when Int, Bool
          expression.class
        when Reference
          table.column_type(expression.name)
        end
      end

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

      def type_operator(operator, operand_types)
        case operator
        when '+', '-', '*', '/'
          if operand_types.all? { |type| type == Int }
            Int
          else
            raise ValidationError, "Invalid types for operator #{operator}: #{operand_types}"
          end
        when 'NOT'
          if operand_types == [Bool]
            Bool
          else
            raise ValidationError, "Invalid types for operator #{operator}: #{operand_types}"
          end
        when 'AND', 'OR'
          if operand_types == [Bool, Bool]
            Bool
          else
            raise ValidationError, "Invalid types for operator #{operator}: #{operand_types}"
          end
        when '<', '>', '>=', '<=', '=', '<>'
          if [[Int, Int], [Bool, Bool]].include?(operand_types)
            Bool
          else
            raise ValidationError, "Invalid types for operator #{operator}: #{operand_types}"
          end
        else
          raise "unknown operator #{operator}"
        end
      end

      def type_function(name, argument_types)
        case name
        when 'ABS'
          if argument_types == [Int]
            Int
          else
            raise ValidationError, "Invalid types for function #{name}: #{argument_types}"
          end
        when 'MOD'
          if argument_types == [Int, Int]
            Int
          else
            raise ValidationError, "Invalid types for function #{name}: #{argument_types}"
          end
        else
          raise ValidationError, "unknown function #{name}"
        end
      end

      def evaluate_list(expressions, row, table)
        expressions.map { |expression| evaluate(expression, row, table) }
      end

      def type_list(expressions, table)
        expressions.map { |expression| type(expression, table) }
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
