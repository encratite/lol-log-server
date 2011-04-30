require 'nil/string'

require 'www-library/RequestHandler'

require 'application/SiteContainer'
require 'application/error'
require 'application/ChampionPerformance'

require 'visual/PlayerHandler'

class PlayerHandler < SiteContainer
  attr_reader :playerHandler

  def installHandlers
    @playerHandler = WWWLib::RequestHandler.handler('player', method(:viewPlayer), 1)
    addHandler(@playerHandler)
  end

  def viewPlayer(request)
    playerIdString = request.arguments.first
    if !playerIdString.isNumber
      argumentError
    end
    playerId = playerIdString.to_i
    result = @database[:player_result].select(:summoner_name).where(user_id: playerId).limit(1).all
    if result.empty?
      argumentError
    end
    playerName = result.first[:summoner_name]
    title = playerName
    defeats = getPlayerPerformance(playerId, :defeated_team_id)
    victories = getPlayerPerformance(playerId, :victorious_team_id)
    championData = {}
    sortByChampion(defeats, championData, false)
    sortByChampion(victories, championData, true)
    content = renderPlayer(playerName, defeats, victories, championData.values)
    return @generator.get(content, request, title)
  end

  def getPlayerPerformance(playerId, teamSymbol)
    return @database[:game_result].left_outer_join(:team_player, team_id: teamSymbol).left_outer_join(:player_result, id: :player_id).where(user_id: playerId).all
  end

  def sortByChampion(games, championData, isVictory)
    games.each do |game|
      performance = ChampionPerformance.new(game, isVictory)
      key = performance.champion
      if championData[key] == nil
        championData[key] = performance
      else
        championData[key].combine(performance)
      end
    end
  end
end
