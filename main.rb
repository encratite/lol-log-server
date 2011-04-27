require_relative 'Configuration'
require_relative 'LogServer'

address = Configuration::Address
port = Configuration::Port
server = LogServer.new(address, port)
puts "Running logging server on #{address}:#{port}"
server.acceptLoop
