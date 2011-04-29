$:.concat ['.', '..']

require 'configuration/Configuration'

require 'application/LoLSite'
require 'application/OverviewHandler'
require 'application/PlayerHandler'

lolSite = LoLSite.new(DatabaseConfiguration, SiteConfiguration)
playerHandler = PlayerHandler.new(lolSite)
OverviewHandler.new(lolSite, playerHandler)

handler = lambda do |environment|
  lolSite.requestManager.handleRequest(environment)
end

run(handler)
