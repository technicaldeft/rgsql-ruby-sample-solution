module RgSql
  class Expression
    class << self
      include Nodes

      def resolve_references(expression, metadata = RowMetadata.empty)
        case expression
        when Operator
          expression.operands.each { |operand| resolve_references(operand, metadata) }
        when Function
          expression.arguments.each { |argument| resolve_references(argument, metadata) }
        when Reference
          metadata.resolve_reference(expression)
        end
      end

      def replace_stored_expressions(expression, metadata)
        if (stored_expression = metadata.resolve_stored_expression(expression))
          Reference.for_stored_expression(stored_expression)
        elsif expression.is_a?(Operator)
          Operator.new(expression.operator, replace_list(expression.operands, metadata))
        elsif expression.is_a?(Function)
          Function.new(expression.name, replace_list(expression.arguments, metadata))
        else
          expression
        end
      end

      def partially_evaluate(aggregate_expression, row, state, metadata)
        arguments = evaluate_list(aggregate_expression.arguments, row, metadata.before_grouping)

        Callable.find_function(aggregate_expression.name).call_aggregate(state, *arguments)
      end

      def type(expression, metadata = RowMetadata.empty)
        case expression
        when Operator
          type_operator(expression, type_list(expression.operands, metadata))
        when Function
          type_function(expression, metadata)
        when Int, Bool, Null
          expression.class
        when Reference
          metadata.reference_type(expression)
        end
      end

      def evaluate(expression, row = [], metadata = nil)
        case expression
        when Operator
          operands = evaluate_list(expression.operands, row, metadata)
          Callable.find_operator(expression.operator).call(operands)
        when Function
          arguments = evaluate_list(expression.arguments, row, metadata)
          Callable.find_function(expression.name).call(arguments)
        when Reference
          metadata.get_reference(row, expression)
        when Int, Bool, Null
          expression
        else
          raise "unknown expression #{expression.inspect} of type #{expression.class}"
        end
      end

      def aggregate_parts(expression)
        case expression
        when Function
          function = Callable.find_function(expression.name)
          if function.aggregate?
            [expression]
          else
            expression.arguments.flat_map { |argument| aggregate_parts(argument) }
          end
        when Operator
          expression.operands.flat_map { |operand| aggregate_parts(operand) }
        else
          []
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

      def type_function(expression, metadata)
        function = Callable.find_function(expression.name)

        if function.aggregate? && !metadata.grouped?
          raise ValidationError, 'Cannot use aggregate function within another aggregate function'
        end

        metadata = metadata.before_grouping if function.aggregate?
        argument_types = type_list(expression.arguments, metadata)

        unless function.accepts_types?(argument_types)
          raise(ValidationError, "Function #{expression.name} does not accept types #{argument_types}")
        end

        function.output_type
      end

      def evaluate_list(expressions, row, metadata)
        expressions.map { |expression| evaluate(expression, row, metadata) }
      end

      def type_list(expressions, metadata)
        expressions.map { |expression| type(expression, metadata) }
      end

      def replace_list(expressions, metadata)
        expressions.map { |expression| replace_stored_expressions(expression, metadata) }
      end
    end
  end
end
