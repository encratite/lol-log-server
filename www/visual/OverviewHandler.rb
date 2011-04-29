require 'www-library/HTMLWriter'

require 'application/SiteContainer'

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

  def renderOverview(resultsMap)
    writer = WWWLib::HTMLWriter.new
    writer.table do
      writer.tr do
        columns = [
          'Date',
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
          writer.td { gameResults[:time_finished].getutc.to_s }
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
    return writer.output
  end
end
