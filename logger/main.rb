require_relative '../configuration/Configuration'
require_relative 'LogServer'

address = LoggerConfiguration::Address
port = LoggerConfiguration::Port
server = LogServer.new(LoggerConfiguration, DatabaseConfiguration)
puts "Running logging server on #{address}:#{port}"
server.acceptLoop
