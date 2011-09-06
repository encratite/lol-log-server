def parseMonthString(monthString)
  monthStrings = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ]
  return monthStrings.index(monthString)
end

def parseDate(input)
  pattern = /^.+? (.+?) (\d+) (\d+):(\d+):(\d+) GMT(\+|-)(\d\d)(\d\d) (\d+)$/
  match = input.match(pattern)
  return nil if match == nil
  month = parseMonthString(match[1])
  return nil if month == nil
  day = match[2].to_i
  hour = match[3].to_i
  minute = match[4].to_i
  second = match[5].to_i
  timeZoneSign = match[6] == '+' ? 1 : -1
  timeZoneHours = match[7].to_i
  timeZoneMinutes = match[8].to_i
  year = match[9].to_i
  output = Time.gm(year, month, day, hour, minute, second) + timeZoneSign * (timeZoneHours * 60 + timeZoneMinutes) * 60
  return output
end
