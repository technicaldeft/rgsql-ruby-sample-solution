module RgSql
  module Nodes
    Int = Data.define(:value) do
      def to_i
        value
      end

      def <=>(other)
        if other.is_a? Null
          -1
        else
          value <=> other.value
        end
      end
    end

    Bool = Data.define(:value) do
      def to_i
        value ? 1 : 0
      end

      def <=>(other)
        if other.is_a? Null
          -1
        else
          to_i <=> other.to_i
        end
      end
    end

    Null = Data.define do
      def value
        nil
      end

      def <=>(other)
        if other.is_a? Null
          0
        else
          1
        end
      end
    end

    Select = Data.define(:select_list, :table, :where, :order, :limit, :offset, :join)
    SelectListItem = Data.define(:name, :expression)
    Join = Data.define(:table_name, :type, :table_alias, :expression)
    Order = Data.define(:expression, :ascending)
    CreateTable = Data.define(:table, :columns)
    Column = Data.define(:name, :type)
    DropTable = Data.define(:table, :if_exists)
    Insert = Data.define(:table, :rows)
    Operator = Data.define(:operator, :operands)
    Function = Data.define(:name, :arguments)

    class Reference
      attr_reader :name
      attr_accessor :resolved

      def initialize(name)
        @name = name
      end
    end
  end
end
