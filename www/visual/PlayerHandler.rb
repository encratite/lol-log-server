require 'www-library/HTMLWriter'

require 'application/SiteContainer'

class PlayerHandler < SiteContainer
  def renderPlayer(playerName, defeats, victories)
    writer = WWWLib::HTMLWriter.new
    gameCount = defeats.size + victories.size
    winRatio = sprintf('%.1f', victories.size.to_f / gameCount * 100.0)
    writer.ul do
      writer.li { "Name: #{playerName}" }
      writer.li { "Number of victories: #{victories.size}" }
      writer.li { "Number of defeats: #{defeats.size}" }
      writer.li { "Total number of games recorded: #{gameCount}" }
      writer.li { "Win ratio: #{winRatio}" }
    end
    return writer.output
  end
end
