require 'www-library/RequestManager'
require 'www-library/RequestHandler'

require 'application/LoLSiteGenerator'
require 'shared/database'

class LoLSite
  attr_reader :mainHandler, :generator, :requestManager, :database, :configuration

  def initialize(databaseConfiguration, siteConfiguration)
    @requestManager = WWWLib::RequestManager.new
    @mainHandler = WWWLib::RequestHandler.new('lol')
    @requestManager.addHandler(@mainHandler)
    @generator = LoLSiteGenerator.new(self, @requestManager)
    base = 'league-of-legends'
    @generator.addStylesheet(getStylesheet(base))
    @generator.setIcon(getIcon(base))
    @database = getDatabase(databaseConfiguration)
    @configuration = siteConfiguration
  end

  def getStaticPath(base, path)
    return @mainHandler.getPath(*(['static', base] + path))
  end

  def getStylesheet(name)
    getStaticPath('style', [name + '.css'])
  end

  def getImage(*path)
    getStaticPath('image', path)
  end

  def getIcon(name)
    getStaticPath('icon', [name + '.ico'])
  end
end
