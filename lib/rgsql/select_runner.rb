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

      @metadata = RowMetadata.from_table(@table)
    end

    def validate
      validate_join(select.join) if select.join
      validate_where(select.where) if select.where
      validate_grouping(select.grouping) if select.grouping
      validate_select_list(select.select_list)
      validate_order(select.order) if select.order
      validate_limit(select.limit) if select.limit
      validate_offset(select.offset) if select.offset
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

    def validate_join(join)
      join_table = database.get_table(join.table_name)
      metadata.add_table(join_table, join.table_alias)
      join.expression.resolve_references(metadata)
      unless Types.match?(Nodes::Bool, join.expression.type(metadata))
        raise ValidationError, 'join clause must evaluate to a boolean'
      end
    end

    def validate_where(where)
      where.resolve_references(metadata)
      raise ValidationError, 'where clause must evaluate to a boolean' unless Types.match?(Bool, where.type(metadata))
    end

    def validate_grouping(grouping)
      grouping.resolve_references(metadata)
      type = grouping.type(metadata)

      metadata.add_grouping(grouping, type)
    end

    def validate_select_list(select_list)
      select_list.each do |item|
        expression = item.expression
        expression.resolve_references(metadata.before_grouping)
        store_aggregate_parts(expression)
      end

      select_list.each do |item|
        expression = item.expression
        expression.replace_stored_expressions(metadata)
        type = expression.type(metadata)
        metadata.add_select_list_item(item.name, type)
      end
    end

    def validate_order(order)
      order.expression.resolve_order_by_reference(metadata) || order.expression.resolve_references(metadata)

      order.expression.type(metadata)
    end

    def validate_limit(limit)
      limit.resolve_references
      raise ValidationError, 'limit must evaluate to the type integer' unless Types.match?(Int, limit.type)
    end

    def validate_offset(offset)
      offset.resolve_references
      raise ValidationError, 'offset must evaluate to the type integer' unless Types.match?(Int, offset.type)
    end

    def build_iterator_chain
      chain = Iterators::Loader.new(@table)
      chain = Iterators::Join.new(chain, metadata.before_grouping, select.join, database) if select.join
      chain = Iterators::Filter.new(chain, metadata.before_grouping, select.where) if select.where
      chain = Iterators::Group.new(chain, metadata, select.grouping) if select.grouping
      chain = Iterators::Project.new(chain, metadata, select.select_list)
      chain = Iterators::Order.new(chain, metadata, select.order) if select.order
      chain = Iterators::Offset.new(chain, select.offset) if select.offset
      chain = Iterators::Limit.new(chain, select.limit) if select.limit
      chain
    end

    def store_aggregate_parts(expression)
      expression.aggregate_parts.each do |aggregate_expression|
        type = Expression.type(aggregate_expression, metadata.before_grouping)
        metadata.store_aggregate_expression(aggregate_expression, type)
      end
    end
  end
end
