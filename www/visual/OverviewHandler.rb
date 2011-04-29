require 'www-library/HTMLWriter'

require 'application/SiteContainer'
require 'application/time'

class OverviewHandler < SiteContainer
  def processTeam(writer, team)
    writer.td do
      first = true
      team.each do |player|
        if first
          first = false
        else
          writer.write(', ')
        end
        writer.a(href: '') do
          player[:summoner_name]
        end
      end
      nil
    end
  end

  def renderOverview(resultsMap, gameCount, page, pageCount)
    writer = WWWLib::HTMLWriter.new
    writer.p do
      "This is an overview of the end of game stats stored in the database. Showing page #{page} of #{pageCount}. The database contains #{gameCount} game(s) overall."
    end
    writer.table(class: 'gameTable') do
      writer.tr do
        columns = [
          'End of game',
          'Defeated team',
          'Victorious team',
          'Duration',
          ]
        columns.each do |column|
          writer.th do
            column
          end
        end
      end
      resultsMap.each do |gameResults, teams|
        writer.tr do
          writer.td { getTimeString(gameResults[:time_finished]) }
          teams.each do |team|
            processTeam(writer, team)
          end
          duration = gameResults[:duration]
          secondsPerMinute = 60
          minutes = duration / secondsPerMinute
          seconds = duration % secondsPerMinute
          durationString = sprintf('%d:%02d', minutes, seconds)
          writer.td { durationString }
        end
      end
      nil
    end
    if pageCount > 1
      writer.table(class: 'pageLinks') do
        writer.tr do
          pageWriter = lambda do |step, description, style|
            writer.td(class: style) do
              increment = page + step
              target = @overviewHandler.getPath(increment.to_s)
              if increment < 1 || increment > pageCount
                ''
              else
                writer.a(href: target) do
                  description
                end
              end
            end
                    end
          pageWriter.call(-1, 'Previous page', 'previousPage')
          pageWriter.call(1, 'Next page', 'nextPage')
        end
      end
    end
    return writer.output
  end
end
