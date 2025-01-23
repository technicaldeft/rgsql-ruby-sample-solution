module RgSql
  class Tokenizer
    KEYWORDS = %w[
      SELECT FROM AS BOOLEAN INTEGER CREATE DROP TABLE IF EXISTS INSERT INTO VALUES
    ].freeze
    BOOLEANS = %w[TRUE FALSE].freeze

    WORD_PATTERN = /\A[a-z_][a-z_\d]*/i
    INTEGER_PATTERN = /\A-?\d+/
    SYMBOLS_PATTERN = /\A\(|\)|,|;/

    Token = Data.define(:type, :value)

    attr_reader :tokens, :rest

    def initialize(sql)
      @rest = sql.lstrip
      @tokens = []
    end

    def tokenize
      consume_token until @rest.empty?
      tokens
    end

    private

    def consume_token
      @tokens << if (match = rest.match(WORD_PATTERN))
                   tokenize_word(match.to_a.first)
                 elsif (match = rest.match(INTEGER_PATTERN))
                   Token.new(:integer, match.to_a.first.to_i)
                 elsif (match = rest.match(SYMBOLS_PATTERN))
                   Token.new(:symbol, match.to_a.first)
                 else
                   raise ParsingError, "Unexpected token: `#{rest}`"
                 end

      @rest = match.post_match.lstrip
    end

    def tokenize_word(word)
      if KEYWORDS.include?(word.upcase)
        Token.new(:keyword, word.upcase)
      elsif BOOLEANS.include?(word.upcase)
        Token.new(:boolean, word.upcase)
      else
        Token.new(:identifier, word)
      end
    end
  end
end
