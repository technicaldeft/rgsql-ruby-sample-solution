module RgSql
  class ExpressionWrapper
    attr_reader :expression

    def initialize(expression)
      @expression = expression
    end

    def contents
      expression
    end

    def ==(other)
      expression == other
    end

    def evaluate(...)
      Expression.evaluate(expression, ...)
    end

    def type(...)
      Expression.type(expression, ...)
    end

    def resolve_references(...)
      Expression.resolve_references(expression, ...)
    end

    def resolve_order_by_reference(metadata)
      metadata.resolve_order_by_reference(expression) if reference?
    end

    def replace_stored_expressions(metadata)
      @expression = Expression.replace_stored_expressions(expression, metadata)
    end

    def aggregate_parts
      Expression.aggregate_parts(expression)
    end

    def name
      expression.name if reference?
    end

    private

    def reference?
      expression.is_a?(Nodes::Reference)
    end
  end
end
