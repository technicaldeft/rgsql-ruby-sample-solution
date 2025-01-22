require 'socket'
require 'json'

module RgSql
  class Server
    def initialize
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
      ast = Parser.new(sql).to_ast
      row, column_names = Runner.new(ast).execute

      { status: 'ok', rows: [row], column_names: }.to_json
    rescue ParsingError => e
      { status: 'error', error_type: 'parsing_error', error_message: e.message }.to_json
    end
  end
end
