require 'nil/string'

require 'www-library/RequestHandler'

require 'application/SiteContainer'
require 'application/error'
require 'visual/OverviewHandler'

class OverviewHandler < SiteContainer
  def installHandlers
    overviewHandler = WWWLib::RequestHandler.handler('overview', method(:overview), 1)
    addHandler(overviewHandler)
  end

  def getTeamData(teamId)
    return @database[:team_player].where(team_id: teamId).left_outer_join(:player_result, :team_player__player_id => :player_result__id).select(:player_result__user_id, :player_result__summoner_name)
  end

  def overview(request)
    pageString = request.arguments.first
    if !pageString.isNumber
      argumentError
    end
    page = pageString.to_i
    gamesPerPage = @configuration::OverviewGamesPerPage
    gameCount = @database[:game_result].count
    pageCount = (gameCount / gamesPerPage).ceil
    if page < 1 || page > pageCount
      argumentError
    end
    offset = (page - 1) * gamesPerPage
    gameResults = @database[:game_result].select(:id, :time_finished, :duration, :defeated_team_id, :victorious_team_id).reverse_order(:time_finished).limit(gamesPerPage, offset)
    resultsMap = {}
    gameResults.each do |result|
      teams = [:defeated_team_id, :victorious_team_id].map do |symbol|
        getTeamData(result[symbol])
      end
      resultsMap[result] = teams
    end
    content = renderOverview(resultsMap, gameCount, page, pageCount)
    title = "Overview (#{page}/#{pageCount})"
    return @generator.get(content, request, title)
  end
end
