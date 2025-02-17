module RgSql
  module Iterators
    class Join
      def initialize(previous_iterator, metadata, join, database)
        @left_iterator = previous_iterator
        @right_table = database.get_table(join.table_name)

        @join = join
        @found_rows = []

        @metadata = metadata
      end

      def next
        return next_found_row if @found_rows.any?

        while (left_row = @left_iterator.next)
          @found_rows = find_matching_rows(left_row)

          if @found_rows.any?
            return next_found_row
          elsif keep_unmatched_left_rows?
            return left_row + @right_table.padded_row
          end
        end
      end

      private

      def keep_unmatched_left_rows?
        @join.type == :left
      end

      def next_found_row
        @found_rows.shift
      end

      def find_matching_rows(left_row)
        @right_table.rows.filter_map do |right_row|
          row = left_row + right_row
          result = Expression.evaluate(@join.expression, row, @metadata)
          row if result == Nodes::Bool.new(true)
        end
      end
    end
  end
end
