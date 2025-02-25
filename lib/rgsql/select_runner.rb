module RgSql
  class SelectRunner
    include Nodes

    attr_reader :database, :select, :metadata

    def initialize(database, select)
      @database = database
      @select = select
      @table = if select.table
                 database.get_table(select.table)
               else
                 Table.empty
               end

      @metadata = RowMetadata.new(@table)
    end

    def validate
      unless Types.match?(Bool, Expression.type(select.where, metadata))
        raise ValidationError, 'where clause must evaluate to a boolean'
      end

      select.select_list.each do |item|
        type = Expression.type(item.expression, metadata)
        metadata.add_select_list_item(item.name, type)
      end

      Expression.type(select.order.expression, metadata) if select.order

      unless Types.match?(Int, Expression.type(select.limit))
        raise ValidationError, 'limit must evaluate to the type integer'
      end

      unless Types.match?(Int, Expression.type(select.offset))
        raise ValidationError, 'offset must evaluate to the type integer'
      end
    end

    def run
      iterator = build_iterator_chain
      output_rows = []
      while (row = iterator.next)
        output_rows << metadata.get_select_list(row).map(&:value)
      end

      {
        status: 'ok',
        rows: output_rows,
        column_names: select.select_list.map(&:name)
      }
    end

    private

    def build_iterator_chain
      chain = Iterators::Loader.new(@table)
      chain = Iterators::Filter.new(chain, metadata, select.where)
      chain = Iterators::Project.new(chain, metadata, select.select_list)
      chain = Iterators::Order.new(chain, metadata, select.order) if select.order
      chain = Iterators::Offset.new(chain, select.offset)
      Iterators::Limit.new(chain, select.limit)
    end
  end
end
