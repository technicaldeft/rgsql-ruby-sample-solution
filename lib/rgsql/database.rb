module RgSql
  class Database
    def initialize
      @tables = {}
    end

    def insert(name, rows)
      @tables[name].insert(rows)
    end

    def get_table(name)
      @tables.fetch(name)
    end

    def create_table(name, columns)
      raise ValidationError, "table `#{name}` already exists" if @tables[name]

      @tables[name] = Table.new(name, columns)
    end

    def drop_table(name, if_exists)
      raise ValidationError, "table `#{name}` does not exist" unless if_exists || @tables[name]

      @tables.delete(name)
    end
  end
end
