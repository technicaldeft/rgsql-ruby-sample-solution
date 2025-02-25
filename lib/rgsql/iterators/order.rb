module RgSql
  module Iterators
    class Order
      def initialize(previous_iterator, metadata, order)
        @previous_iterator = previous_iterator
        @metadata = metadata
        @order = order
      end

      def next
        sort_rows unless @rows
        @rows.shift
      end

      private

      def sort_rows
        @rows = []

        while (row = @previous_iterator.next)
          @rows << row
        end

        @rows.sort! do |row_a, row_b|
          comparison_value(row_a, row_b)
        end
      end

      def comparison_value(row_a, row_b)
        value_a = Expression.evaluate(@order.expression, row_a, @metadata)
        value_b = Expression.evaluate(@order.expression, row_b, @metadata)

        if @order.ascending
          value_a <=> value_b
        else
          value_b <=> value_a
        end
      end
    end
  end
end
