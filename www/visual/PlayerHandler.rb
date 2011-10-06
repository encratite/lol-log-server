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
  def renderStats(writer, stats)
    writer.ul(class: 'playerStats') do
      stats.each do |description, value|
        writer.li do
          writer.b { "#{description}:" }
          writer.write " #{value}"
        end
      end
    end
  end

  def renderPlayer(summonerName, queueTypeResults)
    writer = WWWLib::HTMLWriter.new
    if summonerName != nil
      stats = [
        ['Summoner name', summonerName],
      ]
      renderStats(writer, stats)
    end
    queueTypeResults.each do |queueTypeResult|
      defeats = queueTypeResult.defeats
      victories = queueTypeResult.victories
      championData = queueTypeResult.championData
      gameCount = defeats.size + victories.size
      winRatio = percentageString(victories.size.to_f / gameCount)
      stats = [
        ['Queue type', queueTypeResult.queueType],
      ]
      if summonerName == nil
        stats += [
          ['Samples', victories.size],
        ]
      else
        stats += [
          ['Games', gameCount],
          ['Victories', victories.size],
          ['Defeats', defeats.size],
          ['Win ratio', winRatio],
        ]
      end
      renderStats(writer, stats)
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
              if summonerName == nil
                path = @totalHandler.getPath(columnString)
              else
                path = @playerHandler.getPath(summonerName, columnString)
              end
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
