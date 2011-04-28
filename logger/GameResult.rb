require_relative 'PlayerResult'

class GameResult
  def initialize(root)
    @id = root.get(:gameId)
    @time = Time.at(root.get(:timestamp) / 1000).getutc
    @gameType = root.get(:gameType)
    @duration = root.get(:gameLength)
    @elo = root.get(:elo)
    @eloChange = root.get(:eloChange)
    @ipEarned = root.get(:ipEarned)
    @ipTotal = root.get(:ipTotal)
    ownTeam = getTeamPlayers(root, :teamPlayerParticipantStats)
    otherTeam = getTeamPlayers(root, :otherTeamPlayerParticipantStats)
    if ownTeam.size != otherTeam.size
      raise "Team sizes are not equal: #{ownTeam.size} != #{otherTeam.size}"
    end
    if ownTeam.empty?
      raise 'Encountered a team without players'
    end
    ownTeam, otherTeam = [ownTeam, otherTeam].map do |team|
      team.map do |player|
        PlayerResult.new(player)
      end
    end
    @playerWasVictorious = ownTeam.first.victorious
    if @playerWasVictorious
      @defeatedTeam = otherTeam
      @victoriousTeam = ownTeam
    else
      @defeatedTeam = ownTeam
      @victoriousTeam = otherTeam
    end
  end

  def getTeamPlayers(root, symbol)
    return root.get(symbol, :list, :source)
  end

  def processTeam(team, database)
    teamId = database[:team].insert
    team.each do |player|
      fields = player.getDatabaseFields
      playerId = database[:player_result].insert(fields)
      fields = {
        team_id: teamId,
        player_id: playerId,
      }
      database[:team_player].insert(fields)
    end
    return teamId
  end

  def insertIntoDatabase(database)
    defeatedTeamId = processTeam(@defeatedTeam, database)
    victoriousTeamId = processTeam(@victoriousTeam, database)

    gameResults = database[:game_result]

    if !gameResults.where(game_id: @id).empty?
      puts "Game #{@id} is already in the database - skipping"
      return
    end

    fields = {
      game_id: @id,

      time_finished: @time,
      game_type: @gameType,
      duration: @duration,

      elo: @elo,
      elo_change: @eloChange,

      ip_earned: @ipEarned,
      ip_total: @ipTotal,

      player_was_victorious: @playerWasVictorious,

      defeated_team_id: defeatedTeamId,
      victorious_team_id: victoriousTeamId,
    }
    gameResults.insert(fields)
  end
end
