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
    @generator.addStylesheet(getStylesheet('league-of-legends'))
    @database = getDatabase(databaseConfiguration)
    @configuration = siteConfiguration
  end

  def getStaticPath(base, file)
    return @mainHandler.getPath('static', base, file)
  end

  def getStylesheet(name)
    getStaticPath('style', name + '.css')
  end

  def getImage(file)
    getStaticPath('image', file)
  end
end
