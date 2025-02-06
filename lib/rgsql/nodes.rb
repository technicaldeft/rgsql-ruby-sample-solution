module RgSql
  module Nodes
    Int = Data.define(:value) do
      def to_i
        value
      end
    end

    Bool = Data.define(:value) do
      def to_i
        value ? 1 : 0
      end
    end

    Select = Data.define(:select_list, :table)
    SelectListItem = Data.define(:name, :expression)
    CreateTable = Data.define(:table, :columns)
    Column = Data.define(:name, :type)
    DropTable = Data.define(:table, :if_exists)
    Insert = Data.define(:table, :rows)
    Reference = Data.define(:name)
    Operator = Data.define(:operator, :operands)
    Function = Data.define(:name, :arguments)
  end
end
