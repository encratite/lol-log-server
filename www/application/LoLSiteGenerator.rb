require 'visual/LoLSiteGenerator'

require 'www-library/SiteGenerator'

class LoLSiteGenerator < WWWLib::SiteGenerator
  Name = 'League of Legends Stats'

  def initialize(site, manager)
    super(manager)
    @site = site
  end

  def get(content, request, title)
    content = render(request, content)
    fullTitle = "#{title} - #{Name}"
    super(fullTitle, content)
  end
end
