require 'digest/sha1'

require_relative 'PlayerResult'

class GameResult
  def initialize(time, contents, root)
    @time = time
    @contents = contents
    @hash = Digest::SHA1.digest(contents)
    @gameMode = root.get(:gameMode)
    @gameType = root.get(:gameType)
    @queueType = root.get(:queueType)
    @duration = root.get(:gameLength)
    @elo = root.get(:elo)
    @eloChange = root.get(:eloChange)
    @ipEarned = root.get(:ipEarned)
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

  def insertIntoDatabase(database, address)
    defeatedTeamId = processTeam(@defeatedTeam, database)
    victoriousTeamId = processTeam(@victoriousTeam, database)

    gameResults = database[:game_result]

    if !gameResults.where(log_hash: @hash.to_sequel_blob).empty?
      puts "Game #{@time} is already in the database - skipping"
      return
    end

    fields = {
      log_data: @contents,

      log_hash: @hash.to_sequel_blob,

      time_finished: @time,

      game_mode: @gameMode,
      game_type: @gameType,

      queue_type: @queueType,
      duration: @duration,

      elo: @elo,
      elo_change: @eloChange,

      ip_earned: @ipEarned,

      player_was_victorious: @playerWasVictorious,

      defeated_team_id: defeatedTeamId,
      victorious_team_id: victoriousTeamId,

      uploader_address: address,
    }

    gameResults.insert(fields)
  end
end
