module RgSql
  module Iterators
    class Loader
      def initialize(table)
        @table = table
        @index = 0
      end

      def next
        row = @table.rows[@index]
        @index += 1
        row
      end

      def reset
        @index = 0
      end
    end
  end
end
