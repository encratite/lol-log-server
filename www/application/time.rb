def getTimeString(input)
  return input.getutc.to_s.gsub(' UTC', '')
end
