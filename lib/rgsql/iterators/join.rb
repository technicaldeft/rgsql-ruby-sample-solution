module RgSql
  module Iterators
    class Join
      def initialize(previous_iterator, metadata, join, database)
        @left_iterator = previous_iterator
        @right_table = database.get_table(join.table_name)

        @join = join
        @found_rows = []
        @matched_right_rows = Set.new

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

        next_unmatched_right_row if keep_unmatched_right_rows?
      end

      private

      def keep_unmatched_left_rows?
        @join.type == :left
      end

      def keep_unmatched_right_rows?
        @join.type == :right
      end

      def next_found_row
        @found_rows.shift
      end

      def next_unmatched_right_row
        @unmatched_right_rows ||= find_unmatched_right_rows
        if (right_row = @unmatched_right_rows.shift)
          null_row = @metadata.row_for_unmatched_right_join(@join.table_alias)
          null_row + right_row
        end
      end

      def find_matching_rows(left_row)
        @right_table.rows.filter_map.with_index do |right_row, index|
          row = left_row + right_row
          result = Expression.evaluate(@join.expression, row, @metadata)
          if result == Nodes::Bool.new(true)
            @matched_right_rows.add(index)
            row
          end
        end
      end

      def find_unmatched_right_rows
        @right_table.rows.filter.with_index do |_right_row, index|
          !@matched_right_rows.include?(index)
        end
      end
    end
  end
end
