require 'socket'

require_relative 'Client'

class LogServer
  def initialize(address, port)
    @server = TCPServer.open(address, port)
  end

  def acceptLoop
    while true
      client = @server.accept
      Thread.start(client) do |socket|
        Client.new(socket).process
      end
    end
  end
end
