module RgSql
  class Statement
    attr_reader :rest

    def initialize(sql)
      @sql = sql
      @rest = sql.lstrip
    end

    def consume(regex)
      match = rest.match(/\A(#{regex})\s*/i)
      return unless match

      @rest = match.post_match
      match.to_a.last
    end
  end
end
