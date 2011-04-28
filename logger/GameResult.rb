require_relative 'PlayerResult'

class GameResult
  def initialize(id, team1, team2)
    @id = id
    if team1.size != team2.size
      raise "Team sizes are not equal: #{team1.size} != #{team2.size}"
    end
    if team1.empty?
      raise 'Encountered a team without players'
    end
    team1, team2 = [team1, team2].map do |team|
      team.map do |player|
        PlayerResult.new(player)
      end
    end
    if team1.first.victorious
      team1, team2 = [team2, team1]
    end
    @defeatedTeam = team1
    @victoriousTeam = team2
  end
end
