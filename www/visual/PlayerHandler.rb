require 'www-library/HTMLWriter'

require 'application/SiteContainer'

def percentageString(input)
  return sprintf('%.1f', input * 100.0) + '%'
end

class Percentage
  attr_reader :percentage

  def initialize(percentage)
    @percentage = percentage
  end

  def to_s
    return percentageString(@percentage)
  end

  def <=>(other)
    @percentage <=> other.percentage
  end
end

class PlayerHandler < SiteContainer
  def renderPlayer(summonerName, defeats, victories, championData)
    writer = WWWLib::HTMLWriter.new
    gameCount = defeats.size + victories.size
    winRatio = percentageString(victories.size.to_f / gameCount)
    stats = [
      ['Summoner name', summonerName],
      ['Total number of games', gameCount],
      ['Victories', victories.size],
      ['Defeats', defeats.size],
      ['Win ratio', winRatio],
    ]
    writer.ul(class: 'playerStats') do
      stats.each do |description, value|
        writer.li do
          writer.b { "#{description}:" }
          writer.write " #{value}"
        end
      end
    end
    writer.table(class: 'championData') do
      writer.tr do
        columns = [
          'Champion',
          'Games played',
          'Win ratio',
          'Kills',
          'Deaths',
          'Assists',
          'KDR',
          'KDA',
          'Minions',
          'Neutral minions',
          #'Gold',
        ]
        columnIndex = 0
        columns.each do |column|
          writer.th do
            columnString = SortableColumns[columnIndex]
            path = @playerHandler.getPath(summonerName, columnString)
            writer.a(href: path) do
              column
            end
          end
          columnIndex += 1
        end
      end
      championData.each do |champion|
        writer.tr do
          champion.columns.each do |value|
            writer.td do
              if value.class == Float
                sprintf('%.1f', value)
              else
                value.to_s
              end
            end
          end
        end
      end
    end
    return writer.output
  end

  def setChampionColumns(champion)
    name = champion.champion
    championWriter = WWWLib::HTMLWriter.new
    championWriter.img(src: @site.getImage('champion', 'small', "#{name}.png"), alt: name)
    championWriter.b { name }

    columns = [
      championWriter.output,
      champion.gameCount,
      Percentage.new(champion.winRatio),
      champion.killsPerGame,
      champion.deathsPerGame,
      champion.assistsPerGame,
      champion.killsPerDeath,
      champion.killsAndAssistsPerDeath,
      champion.minionsKilledPerGame,
      champion.neutralMinionsKilledPerGame,
      #champion.goldPerGame,
    ]

    champion.columns = columns
  end
end
