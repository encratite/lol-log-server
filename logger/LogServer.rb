require 'socket'
require 'sequel'

require_relative 'Client'
require_relative '../shared/database'

class LogServer
  def initialize(loggerConfiguration, databaseConfiguration)
    @server = TCPServer.open(loggerConfiguration::Address, loggerConfiguration::Port)
    @database = getDatabase(databaseConfiguration)
  end

  def acceptLoop
    while true
      client = @server.accept
      Thread.start(client) do |socket|
        Client.new(socket, @database).process
      end
    end
  end
end
