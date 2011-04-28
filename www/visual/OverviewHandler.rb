require 'www-library/HTMLWriter'

require 'application/SiteContainer'

class OverviewHandler < SiteContainer
  def renderOverview
    writer = WWWLib::HTMLWriter.new
    return writer.output
  end
end
