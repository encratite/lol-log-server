require 'www-library/HTMLWriter'

require 'application/SiteContainer'

class PlayerHandler < SiteContainer
  def percentage(input)
    return sprintf('%.1f', input * 100.0) + '%'
  end

  def renderPlayer(playerName, defeats, victories, championData)
    writer = WWWLib::HTMLWriter.new
    gameCount = defeats.size + victories.size
    winRatio = percentage(victories.size.to_f / gameCount)
    stats = [
      ['Summoner name', playerName],
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
          'Gold',
        ]
        columns.each do |column|
          writer.th do
            column
          end
        end
      end
      championData.each do |champion|
        name = champion.champion
        championWriter = WWWLib::HTMLWriter.new
        championWriter.img(src: @site.getImage('champion', 'small', "#{name}.png"), alt: name)
        championWriter.b { name }
        columns = [
          championWriter.output,
          champion.gameCount,
          percentage(champion.winRatio),
          champion.killsPerGame,
          champion.deathsPerGame,
          champion.assistsPerGame,
          champion.killsPerDeath,
          champion.killsAndAssistsPerDeath,
          champion.minionsKilledPerGame,
          champion.neutralMinionsKilledPerGame,
          champion.goldPerGame,
        ]
        writer.tr do
          columns.each do |value|
            writer.td do
              if value.class == Float
                sprintf('%.1f', value)
              else
                value
              end
            end
          end
        end
      end
    end
    return writer.output
  end
end
