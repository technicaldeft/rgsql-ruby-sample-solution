module RgSql
  module Iterators
    class Project
      def initialize(previous_iterator, metadata, select_list)
        @previous_iterator = previous_iterator
        @metadata = metadata
        @select_list = select_list
      end

      def next
        row = @previous_iterator.next
        return nil unless row

        @select_list.each do |item|
          row << Expression.evaluate(item.expression, row, @metadata)
        end

        row
      end
    end
  end
end
