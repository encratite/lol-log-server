require 'visual/LoLSiteGenerator'

require 'www-library/SiteGenerator'

class LoLSiteGenerator < WWWLib::SiteGenerator
  Name = 'League of Legends Stats'

  def initialize(site, manager)
    super(manager)
    @site = site
  end

  def get(content, request, title = nil)
    content = render(title, request, content)
    title = request.handler.menuDescription if title == nil
    title = "#{title} - #{Name}"
    super(title, content)
  end
end
