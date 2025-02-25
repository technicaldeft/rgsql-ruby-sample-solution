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
      validate_where(select.where)
      validate_select_list(select.select_list)
      validate_order(select.order) if select.order
      validate_limit(select.limit)
      validate_offset(select.offset)
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

    def validate_where(where)
      unless Types.match?(Bool, Expression.type(where, metadata))
        raise ValidationError, 'where clause must evaluate to a boolean'
      end
    end

    def validate_select_list(select_list)
      select_list.each do |item|
        type = Expression.type(item.expression, metadata)
        metadata.add_select_list_item(item.name, type)
      end
    end

    def validate_order(order)
      Expression.type(order.expression, metadata)
    end

    def validate_limit(limit)
      raise ValidationError, 'limit must evaluate to the type integer' unless Types.match?(Int, Expression.type(limit))
    end

    def validate_offset(offset)
      unless Types.match?(Int, Expression.type(offset))
        raise ValidationError, 'offset must evaluate to the type integer'
      end
    end

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
