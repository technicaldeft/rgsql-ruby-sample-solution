module RgSql
  class Statement
    def initialize(sql)
      @sql = sql
      @tokens = Tokenizer.new(sql).tokenize
    end

    def empty?
      @tokens.empty?
    end

    def next_token
      @tokens.first
    end

    def consume(type, value = nil)
      return unless next_token && next_token.type == type

      if value.nil? || next_token.value == value
        token = next_token
        @tokens.shift
        token.value
      end
    end

    def consume!(type, value = nil)
      result = consume(type, value)
      raise ParsingError, consume_error_message(type, value) unless result

      result
    end

    private

    def consume_error_message(type, value)
      expectation = if value.nil?
                      type
                    else
                      "#{type} with value `#{value}`"
                    end

      if next_token.nil?
        "expecting token of type #{expectation} but reached end of query"
      else
        "expecting token of type #{expectation} but found #{next_token.type} with value `#{next_token.value}`"
      end
    end
  end
end
