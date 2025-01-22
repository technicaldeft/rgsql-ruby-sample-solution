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

        @socket.print("hello\0")
      end
    end
  end
end
