module RgSql
  class Database
    def initialize
      @tables = {}
    end

    def create_table(name, columns)
      raise ValidationError, "table `#{name}` already exists" if @tables[name]

      column_names = columns.map(&:name)
      raise ValidationError, 'duplicate column name' if column_names.uniq.count < column_names.count

      @tables[name] = true
    end

    def drop_table(name, if_exists)
      raise ValidationError, "table `#{name}` does not exist" unless if_exists || @tables[name]

      @tables.delete(name)
    end
  end
end
