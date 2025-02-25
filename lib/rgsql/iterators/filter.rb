module RgSql
  module Iterators
    class Filter
      def initialize(previous_iterator, metadata, expression)
        @previous_iterator = previous_iterator
        @metadata = metadata
        @expression = expression
      end

      def next
        while (row = @previous_iterator.next)
          return row if @expression.evaluate(row, @metadata) == Nodes::Bool.new(true)
        end
      end
    end
  end
end
