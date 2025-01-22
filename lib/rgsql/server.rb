require 'socket'
require 'json'

module RgSql
  class Server
    attr_reader :database

    def initialize(database)
      @database = database
      @server = TCPServer.new 3003
      @socket = @server.accept
    end

    def run
      loop do
        message = @socket.gets("\0")
        break if message.nil?

        sql = message.chomp("\0")
        response = execute(sql)
        @socket.print response
        @socket.print("\0")
      end
    end

    private

    def execute(sql)
      result = RgSql.run(database, sql)
      result.to_json
    rescue ParsingError => e
      { status: 'error', error_type: 'parsing_error', error_message: e.message }.to_json
    rescue ValidationError => e
      { status: 'error', error_type: 'validation_error', error_message: e.message }.to_json
    end
  end
end
