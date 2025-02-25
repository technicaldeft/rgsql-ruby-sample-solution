module RgSql
  module Iterators
    class Offset
      def initialize(previous_iterator, offset_expression)
        @previous_iterator = previous_iterator
        @offset = offset_expression.evaluate.value
      end

      def next
        while @offset && @offset > 0
          @previous_iterator.next
          @offset -= 1
        end
        @previous_iterator.next
      end
    end
  end
end
