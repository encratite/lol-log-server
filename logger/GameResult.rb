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
end
