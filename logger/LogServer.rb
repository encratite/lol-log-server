require 'socket'
require 'sequel'

require_relative 'Client'

class LogServer
  def initialize(loggerConfiguration, databaseConfiguration)
    @server = TCPServer.open(loggerConfiguration::Address, loggerConfiguration::Port)
    @database = getDatabase(databaseConfiguration)
  end

  def getDatabase(configuration)
    database =
      Sequel.connect(
                     adapter: configuration::Adapter,
                     host: configuration::ServerAddress,
                     user: configuration::User,
                     password: configuration::Password,
                     database: configuration::Database,
                     )

    #run an early test to see if the DBMS is accessible
    database['select 1 where true'].all
    return database
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
