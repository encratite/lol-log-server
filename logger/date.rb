def parseDate(input)
  pattern = /^(\d+)\/(\d+)\/(\d+) (\d+):(\d+):(\d+)\./
  match = input.match(pattern)
  return nil if match == nil
  month = match[1].to_i
  day = match[2].to_i
  year = match[3].to_i
  hour = match[4].to_i
  minute = match[5].to_i
  second = match[6].to_i
  output = Time.gm(year, month, day, hour, minute, second)
  return output
end
