require 'rgsql/server'
require 'rgsql/parser'
require 'rgsql/runner'
require 'rgsql/statement'
require 'rgsql/database'

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
