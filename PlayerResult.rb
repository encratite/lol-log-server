require 'nil/symbol'

require_relative 'LogObject'

class PlayerResult
  include SymbolicAssignment

  Mapping = {
    leaves: :leaves,
    level: :level,
    losses: :losses,
    summonerName: :name,
    skinName: :champion,
    userId: :id,
    wins: :wins,
  }

  StatMapping = {
    'MINIONS_KILLED' => :minionsKilled,
    'PHYSICAL_DAMAGE_TAKEN' => :physicalDamageTaken,
    'PHYSICAL_DAMAGE_DEALT_PLAYER' => :physicalDamageDealt,
    'TOTAL_HEAL' => :amountHealed,
    'ASSISTS' => :assists,
    'GOLD_EARNED' => :gold,
    'LARGEST_CRITICAL_STRIKE' => :largestCriticalStrike,
    'MAGIC_DAMAGE_DEALT_PLAYER' => :magicalDamageDealt,
    'LARGEST_MULTI_KILL' => :largestMultiKill,
    'BARRACKS_KILLED' => :barracksDestroyed,
    'LEVEL' => :level,
    'LARGEST_KILLING_SPREE' => :longestKillingSpree,
    'TOTAL_TIME_SPENT_DEAD' => :timeSpentDead,
    'NEUTRAL_MINIONS_KILLED' => :neutralMinionsKilled,
    'MAGIC_DAMAGE_TAKEN' => :magicalDamageTaken,
    'TURRETS_KILLED' => :turretsDestroyed,
    'NUM_DEATHS' => :deaths,
    'CHAMPIONS_KILLED' => :kills,
  }

  attr_reader :victorious

  def initialize(array)
    root = LogObject.new(nil, nil, array)
    Mapping.each do |sourceSymbol, destinationSymbol|
      value = root.get(sourceSymbol)
      setMember(destinationSymbol, value)
    end

    statistics = {}
    root.get(:statistics, :list, :source).each do |entry|
      entry = LogObject.new(nil, nil, entry)
      name = entry.get(:statTypeName)
      value = entry.get(:value)
      statistics[name] = value
    end

    StatMapping.each do |statName, destinationSymbol|
      value = statistics[statName]
      if value == nil
        raise "Unable to find a stats entry for #{statName.inspect}"
      end
      setMember(destinationSymbol, value)
    end
    @victorious = statistics['LOSE'] == nil
  end
end
