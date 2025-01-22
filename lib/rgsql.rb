require 'rgsql/server'
require 'rgsql/parser'
require 'rgsql/runner'
require 'rgsql/statement'

module RgSql
  class ParsingError < StandardError
  end

  def self.start_server
    Server.new.run
  end
end
