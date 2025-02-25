module RgSql
  module Iterators
    class Group
      def initialize(previous_iterator, metadata, grouping)
        @previous_iterator = previous_iterator
        @metadata = metadata
        @grouping = grouping
      end

      def next
        build_grouping_hash unless @grouping_hash
        _key, row = @grouping_hash.shift
        row
      end

      private

      def build_grouping_hash
        @grouping_hash = {}
        while (row = @previous_iterator.next)
          evaluated_grouping = @grouping.evaluate(row, @metadata)
          @grouping_hash[evaluated_grouping.value] ||= [evaluated_grouping]
        end
      end
    end
  end
end
