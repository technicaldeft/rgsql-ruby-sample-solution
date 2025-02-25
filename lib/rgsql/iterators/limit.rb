module RgSql
  module Iterators
    class Limit
      def initialize(previous_iterator, limit_expression)
        @previous_iterator = previous_iterator
        @limit = limit_expression.evaluate.value
      end

      def next
        return @previous_iterator.next if @limit.nil?

        if @limit == 0
          nil
        else
          row = @previous_iterator.next
          @limit -= 1
          row
        end
      end
    end
  end
end
