require 'nil/symbol'

class ChampionPerformance
  include SymbolicAssignment

  attr_reader :champion, :victories, :defeats

  def initialize(row, isVictory)
    @champion = fixName(row[:champion])

    @kills = row[:kills]
    @deaths = row[:deaths]
    @assists = row[:assists]

    @minionsKilled = row[:minions_killed]
    @neutralMinionsKilled = row[:neutral_minions_killed]

    @gold = row[:gold]

    @defeats = 0
    @victories = 0

    symbol = isVictory ? :victories : :defeats
    setMember(symbol, 1)
  end

  def fixName(input)
    translations = {
      'Voidwalker' => 'Kassadin',
      'Jester' => 'Shaco',
      'Cryophoenix' => 'Anivia',
      'MissFortune' => 'Miss Fortune',
      'Lich' => 'Karthus',
      'KogMaw' => "Kog'Maw",
      'Pirate' => 'Gangplank',
      'Bowmaster' => 'Ashe',
      'MasterYi' => 'Master Yi',
      'GreenTerror' => "Cho'Gath",
      'DarkChampion' => 'Tryndamere',
      'JarvanIV' => 'Jarvan IV',
      'Wolfman' => 'Warwick',
      'CardMaster' => 'Twisted Fate',
      'Chronokeeper' => 'Zilean',
      'DrMundo' => 'Dr. Mundo',
      'FallenAngel' => 'Morgana',
      'XenZhao' => 'Xin Zhao',
      'SteamGolem' => 'Blitzcrank',
      'Judicator' => 'Kayle',
      'ChemicalMan' => 'Singed',
      'SadMummy' => 'Amumu',
      'Armordillo' => 'Rammus',
      'Armsmaster' => 'Jax',
      'Yeti' => 'Nunu',
      'GemKnight' => 'Taric',
      'Minotaur' => 'Alistar',
      'FiddleSticks' => 'Fiddlesticks',
    }
    translation = translations[input]
    if translation != nil
      return translation
    end
    return input
  end

  def combine(performance)
    toCombine = [
      :kills,
      :deaths,
      :assists,

      :minionsKilled,
      :neutralMinionsKilled,

      :gold,

      :defeats,
      :victories
    ]
    toCombine.each do |symbol|
      value = getMember(symbol) + performance.getMember(symbol)
      setMember(symbol, value)
    end
  end

  def gameCount
    return @defeats + @victories
  end

  def winRatio
    return @victories.to_f / gameCount
  end

  def perGameStat(symbol)
    return getMember(symbol).to_f / gameCount
  end

  def killsPerGame
    return perGameStat(:kills)
  end

  def deathsPerGame
    return perGameStat(:deaths)
  end

  def assistsPerGame
    return perGameStat(:assists)
  end

  def killsPerDeath
    return @kills.to_f / @deaths
  end

  def killsAndAssistsPerDeath
    return (@kills + @assists).to_f / @deaths
  end

  def minionsKilledPerGame
    return perGameStat(:minionsKilled)
  end

  def neutralMinionsKilledPerGame
    return perGameStat(:neutralMinionsKilled)
  end

  def goldPerGame
    return perGameStat(:gold)
  end
end
