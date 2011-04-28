require 'nil/symbol'

require_relative 'LogObject'

class PlayerResult
  include SymbolicAssignment

  Mapping = {
    leaves: :leaves,
    level: :summonerLevel,
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
    @items = []
    itemCount = 6
    itemCount.times do |i|
      value = statistics["ITEM#{i}"]
      if value == nil
        raise "Unable to retrieve item #{i}"
      end
      #don't keep track of empty item slots
      next if value == 0
      @items << value
    end
  end

  def getDatabaseFields
    return {
      user_id: @id,

      summoner_name: @name,
      summoner_level: @summonerLevel,

      wins: @wins,
      leaves: @leaves,
      losses: @losses,

      champion: @champion,
      champion_level: @level,

      kills: @kills,
      deaths: @deaths,
      assists: @assists,

      minions_killed: @minionsKilled,
      neutral_minions_killed: @neutralMinionsKilled,

      gold: @gold,

      physical_damage_dealt: @physicalDamageDealt,
      physical_damage_taken: @physicalDamageTaken,

      magical_damage_dealt: @magicalDamageDealt,
      magical_damage_taken: @magicalDamageTaken,

      amount_healed: @amountHealed,

      turrets_destroyed: @turretsDestroyed,
      barracks_destroyed: @barracksDestroyed,

      largest_critical_strike: @largestCriticalStrike,
      largest_multikill: @largestMultiKill,
      longest_killing_spree: @longestKillingSpree,

      time_spent_dead: @timeSpentDead,
    }
  end
end
