require 'nil/string'

require 'www-library/RequestHandler'

require 'application/SiteContainer'
require 'application/error'

require 'visual/PlayerHandler'

class PlayerHandler < SiteContainer
  attr_reader :playerHandler

  def installHandlers
    @playerHandler = WWWLib::RequestHandler.handler('player', method(:viewPlayer), 1)
    addHandler(@playerHandler)
  end

  def viewPlayer(request)
    playerIdString = request.argument.first
    if !playerIdString.isNumber
      argumentError
    end
    playerId = playerIdString.to_i
    result = @database[:player_result].select(:summoner_name).where(player_id: playerId).limit(1).all
    if result.empty?
      argumentError
    end
    playerName = result.first[:summoner_name]
    title = playerName
    playerData = nil
    content = renderPlayer(playerData)
    return @generator.get(content, request, title)
  end
end
