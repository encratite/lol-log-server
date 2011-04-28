require 'nil/string'

require_relative 'LogObject'
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
    output = match[1]
    comparison = output.dup
    output.force_encoding('utf-8')
    if comparison != output
      #puts "#{comparison.inspect} vs. #{output.inspect}"
    end
    return output
  end
  case string
    when '(null)', 'NaN'
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
  #puts "Processing array: #{line} (#{indentation})"
  offset += 1
  while offset < lines.size
    currentIndentation, currentLine = lines[offset]
    if currentIndentation <= indentation
      #puts "Breaking due to indentation"
      break
    end
    #puts "Processing array line: #{currentLine} (#{currentIndentation})"
    offset, children = parseChildren(lines, offset + 1, currentIndentation)
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
  if value.class == LogObjectType && value.isArray
    offset, children = parseArray(lines, offset)
    #puts "Children: #{children.inspect}"
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
