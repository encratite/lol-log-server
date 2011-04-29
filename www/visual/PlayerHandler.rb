require 'www-library/HTMLWriter'

require 'application/SiteContainer'

class PlayerHandler < SiteContainer
  def renderPlayer(playerData)
    writer = WWWLib::HTMLWriter.new
    return writer.output
  end
end
