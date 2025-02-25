module RgSql
  class Tokenizer
    def self.union(array)
      array.map { |value| Regexp.escape(value) }.join('|')
    end

    KEYWORDS = %w[
      SELECT FROM AS BOOLEAN INTEGER CREATE DROP TABLE IF EXISTS INSERT INTO VALUES WHERE ORDER BY ASC DESC
      LIMIT OFFSET
    ].freeze
    BOOLEANS = %w[TRUE FALSE].freeze
    OPERATOR_WORDS = %w[AND NOT OR].freeze
    OPERATOR_SYMBOLS = %w[+ - * / = <> <= >= < >].freeze
    NULL = 'NULL'.freeze

    WORD_PATTERN = /\A[a-z_][a-z_\d\.]*/i
    INTEGER_PATTERN = /\A-?\d+/
    SYMBOLS_PATTERN = /\A\(|\)|,|;/
    OPERATOR_SYMBOLS_PATTERN = /\A(#{union(OPERATOR_SYMBOLS)})/i

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
                 elsif (match = rest.match(OPERATOR_SYMBOLS_PATTERN))
                   Token.new(:operator, match.to_a.first.upcase)
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
      elsif OPERATOR_WORDS.include?(word.upcase)
        Token.new(:operator, word.upcase)
      elsif word.upcase == NULL
        Token.new(:null, word.upcase)
      else
        Token.new(:identifier, word)
      end
    end
  end
end
