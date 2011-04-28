require 'www-library/RequestManager'

class SiteContainer
  attr_reader :title

  def initialize(site)
    @site = site
    @database = site.database
    @generator = site.generator
    @configuration = site.configuration
    installHandlers
  end

  def addHandler(handler)
    @site.mainHandler.add(handler)
  end

  def raiseError(error, request)
    raise WWWLib::RequestManager::Exception.new(@generator.get(error, request))
  end
end
