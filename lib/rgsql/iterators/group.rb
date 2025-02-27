module RgSql
  module Iterators
    class Group
      def initialize(previous_iterator, metadata, grouping)
        @previous_iterator = previous_iterator
        @grouped_metadata = metadata
        @ungrouped_metadata = metadata.before_grouping
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
          add_grouped_row(row)
        end
      end

      def add_grouped_row(row)
        key, grouped_row = evaluate_grouping(row)

        if @grouping_hash.key?(key)
          grouped_row = @grouping_hash[key]
        else
          @grouping_hash[key] = grouped_row
        end

        partially_apply_aggregates(row, grouped_row)
      end

      def evaluate_grouping(row)
        evaluated = @grouping.evaluate(row, @ungrouped_metadata)
        [evaluated.value, [evaluated]]
      end

      def partially_apply_aggregates(row, grouped_row)
        @grouped_metadata.update_each_aggregate_state(grouped_row) do |aggregate, state|
          Expression.partially_evaluate(aggregate, row, state, @ungrouped_metadata)
        end
      end
    end
  end
end
