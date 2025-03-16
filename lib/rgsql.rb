require 'rgsql/nodes'
require 'rgsql/callable'
require 'rgsql/types'
require 'rgsql/tokenizer'
require 'rgsql/server'
require 'rgsql/parser'
require 'rgsql/runner'
require 'rgsql/statement'
require 'rgsql/database'
require 'rgsql/select_runner'
require 'rgsql/table'
require 'rgsql/expression_parser'
require 'rgsql/expression'
require 'rgsql/row_metadata'

require 'rgsql/iterators/filter'
require 'rgsql/iterators/join'
require 'rgsql/iterators/limit'
require 'rgsql/iterators/loader'
require 'rgsql/iterators/offset'
require 'rgsql/iterators/order'
require 'rgsql/iterators/project'
require 'rgsql/iterators/group'

module RgSql
  class ParsingError < StandardError
  end

  class ValidationError < StandardError
  end

  def self.run(database, sql)
    ast = Parser.new(sql).to_ast
    Runner.new(database, ast).execute
  end

  def self.start_server
    database = Database.new
    Server.new(database).run
  end
end
