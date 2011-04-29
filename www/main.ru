$:.concat ['.', '..']

require 'configuration/Configuration'

require 'application/LoLSite'
require 'application/OverviewHandler'
require 'application/PlayerHandler'

lolSite = LoLSite.new(DatabaseConfiguration, SiteConfiguration)
OverviewHandler.new(lolSite)
PlayerHandler.new(lolSite)

handler = lambda do |environment|
  lolSite.requestManager.handleRequest(environment)
end

run(handler)
