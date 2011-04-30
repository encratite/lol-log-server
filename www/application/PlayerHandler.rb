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
    #select count(*) from game_result where exists(select * from team_player, player_result where (team_player.team_id = game_result.defeated_team_id or team_player.team_id = game_result.victorious_team_id) and player_result.user_id = xxx);
    #gameResults = @database[:game_result].filter { @database[:team_player].join(:player_result).filter { {team_player__team_id: :game_result__defeated_team_id, team_player__team_id: :game_result__victorious_team_id}.sql_or & {:player_result__user_id: playerId} }.exists }
    gameResults = @database[:game_result].select(:defeated_team_id, :victorious_team_id).filter(@database.from(:team_player, :player_result).filter(team_player__team_id: :game_result__defeated_team_id).or(team_player__team_id: :game_result__victorious_team_id).and(player_result__user_id: playerId).exists).all
    defeats = getPlayerPerformance(playerId, gameResults, :defeated_team_id)
    victories = getPlayerPerformance(playerId, gameResults, :victorious_team_id)
    content = renderPlayer(playerName, defeats, victories)
    return @generator.get(content, request, title)
  end

  def getPlayerPerformance(playerId, gameResults, teamSymbol)
    output = []
    gameResults.each do |gameResult|
      teamId = gameResult[teamSymbol]
      output += @database[:team_player].filter(team_id: teamId).and(player_id: playerId).join(:player_result, user_id: :player_id).all
    end
    return output
  end
end
