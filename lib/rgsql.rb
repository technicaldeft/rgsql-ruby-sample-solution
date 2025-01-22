require 'rgsql/server'

module RgSql
  def self.start_server
    Server.new.run
  end
end
