require 'set'

require 'nil/string'

require 'www-library/RequestHandler'

require 'application/SiteContainer'
require 'application/error'
require 'application/ChampionPerformance'

require 'visual/PlayerHandler'

class QueueTypeResults
  attr_reader :queueType, :defeats, :victories, :championData

  def initialize(queueType, defeats, victories, championData)
    @queueType = translateQueueType(queueType)
    @defeats = defeats
    @victories = victories
    @championData = championData
  end

  def translateQueueType(queueType)
    translations = {
      'NORMAL' => "Summoner's Rift, normal",
      'RANKED_SOLO_5x5' => "Summoner's Rift, ranked (solo)",
      'ODIN_UNRANKED' => 'Dominion, normal',
    }
    if !translations.has_key?(queueType)
      return queueType
    end
    return translations[queueType]
  end
end

class PlayerHandler < SiteContainer
  attr_reader :playerHandler

  SortableColumns = [
    'champion',
    'gameCount',
    'winRatio',
    'killsPerGame',
    'deathsPerGame',
    'assistsPerGame',
    'champion.killsPerDeath',
    'killsAndAssistsPerDeath',
    'minionsKilledPerGame',
    'neutralMinionsKilledPerGame',
    #'goldPerGame',
  ]

  def installHandlers
    @playerHandler = WWWLib::RequestHandler.handler('player', method(:viewPlayer), 1..2)
    addHandler(@playerHandler)
  end

  def nanHack
    NaN
  end

  def viewPlayer(request)
    arguments = request.arguments
    summonerName = arguments.first
    sortingString = arguments.size == 1 ? SortableColumns.first : arguments[1]
    sortableIndex = SortableColumns.index(sortingString)
    if sortableIndex == nil
      argumentError
    end
    result = @database[:player_result].where(summoner_name: summonerName).limit(1)
    if result.empty?
      argumentError
    end
    title = summonerName
    allDefeats = getPlayerPerformance(summonerName, :defeated_team_id)
    allVictories = getPlayerPerformance(summonerName, :victorious_team_id)
    queueTypes = (allDefeats.keys + allVictories.keys).to_set
    queueTypeResults = []
    queueTypes.each do |queueType|
      defeats = allDefeats[queueType]
      if defeats == nil
        defeats = []
      end
      victories = allVictories[queueType]
      if victories == nil
        victories = []
      end
      championData = {}
      sortByChampion(defeats, championData, false)
      sortByChampion(victories, championData, true)
      championData.each do |key, value|
        setChampionColumns(value)
      end
      championData = championData.values.sort do |x, y|
        translate = lambda do |container, index|
          input = container.columns[index]
          if input.class == Float && (input.nan? || input.infinite?)
            -1.0
          else
            input
          end
        end
        left = translate.call(x, sortableIndex)
        right = translate.call(y, sortableIndex)
        if left.class == String
          left <=> right
        else
          - (left <=> right)
        end
      end
      queueTypeResults << QueueTypeResults.new(queueType, defeats, victories, championData)
    end
    content = renderPlayer(summonerName, queueTypeResults)
    return @generator.get(content, request, title)
  end

  def getPlayerPerformance(summonerName, teamSymbol)
    results = @database[:game_result].left_outer_join(:team_player, team_id: teamSymbol).left_outer_join(:player_result, id: :player_id).where(summoner_name: summonerName).all
    output = {}
    results.each do |result|
      queueType = result[:queue_type]
      if !output.has_key?(queueType)
        output[queueType] = []
      end
      output[queueType] << result
    end
    return output
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
