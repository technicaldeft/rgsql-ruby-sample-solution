module RgSql
  module Nodes
    Int = Data.define(:value)
    Bool = Data.define(:value)

    Select = Data.define(:select_list, :table)
    SelectListItem = Data.define(:name, :value)
    CreateTable = Data.define(:table, :columns)
    Column = Data.define(:name, :type)
    DropTable = Data.define(:table, :if_exists)
    Insert = Data.define(:table, :rows)
    Reference = Data.define(:name)
  end
end
