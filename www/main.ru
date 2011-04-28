$:.concat ['.', '..']

require 'configuration/Configuration'

require 'application/LoLSite'
require 'application/OverviewHandler'

lolSite = LoLSite.new(DatabaseConfiguration, SiteConfiguration)
OverviewHandler.new(lolSite)

handler = lambda do |environment|
  lolSite.requestManager.handleRequest(environment)
end

run(handler)
