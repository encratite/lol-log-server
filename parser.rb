require 'nil/string'

require_relative 'LobObject'
require_relative 'LogObjectType'

def parseLine(line)
  offset = 0
  while offset < line.size && line[offset] == ' '
    offset += 1
  end
  if offset % 2 != 0
    raise "Invalid space count in line: #{line.inspect}"
  end
  indentation = offset / 2
  return [indentation, line[offset..-1]]
end

def translateValue(string)
  if string.isNumber
    return string.to_i
  end
  stringPattern = /^"(.*?)"$/
  match = string.match(stringPattern)
  if match != nil
    return match[1]
  end
  case string
    when '(null)'
      return nil
    when 'false'
      return false
    when 'true'
      return true
  end
  objectPattern = /^\((.+?)\)\#\d+$/
  match = string.match(objectPattern)
  if match == nil
    raise "Unable to determine value type: #{string.inspect}"
  end
  return LogObjectType.new(match[1])
end

def parseArray(lines, offset)
  array = []
  indentation, line = lines[offset]
  #puts "Processing array: #{line} (#{offset})"
  while offset < lines.size
    currentIndentation, currentLine = lines[offset]
    if currentIndentation < indentation
      break
    end
    offset, children = parseChildren(lines, offset + 1, indentation)
    array << children
  end
  #puts "Array output: #{array.inspect} (#{offset})"
  return offset, array
end

def parseChildren(lines, offset, indentation)
  children = []
  while offset < lines.size
    currentIndentation, currentLine = lines[offset]
    if currentIndentation <= indentation
      break
    end
    offset, child = parseBodyObject(lines, offset)
    children << child
  end
  return offset, children
end

def parseBodyObject(lines, offset)
  indentation, line = lines[offset]
  pattern = /^(.+?) = (.+?)$/
  match = line.match(pattern)
  if match == nil
    raise "Unable to parse value: #{line.inspect}"
  end
  name = match[1]
  valueString = match[2]
  value = translateValue(valueString)
  if value.class == LogObjectType && value.type == 'Array'
    offset, children = parseArray(lines, offset + 1)
    puts "Children: #{children.inspect}"
  else
    offset, children = parseChildren(lines, offset + 1, indentation)
  end
  object = LogObject.new(name, value, children)
  return offset, object
end

def parseBody(body)
  lines = body.strip.split("\n").map { |x| parseLine(x) }
  if lines.empty?
    raise "Encountered an empty body"
  end
  offset, root = parseBodyObject(lines, 0)
  return root
end

def interpretTeam(root, symbol)
  root.children.each do |child|
    #puts child.name
  end
  team = root.get(:body, symbol)
  puts team.inspect
  players = team.get(:list, :source)
  puts players.size
end

def interpretBodyObject(root)
  ownTeam = interpretTeam(root, :teamPlayerParticipantStats)
  otherTeam = interpretTeam(root, :otherTeamPlayerParticipantStats)
end
