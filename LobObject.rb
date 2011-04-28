class LogObject
  attr_reader :name, :value, :children

  def initialize(name, value, children)
    @name = name
    @value = value
    @children = children
  end

  def get(*arguments)
    if arguments.empty?
      return @value
    else
      target = arguments.first
      remainingArguments = arguments[1..-1]
      children.each do |child|
        if child.class != LogObject
          raise "Tried to look for #{arguments.inspect} in a non-LogObject (#{child.class})"
        end
        if child.name == target.to_s
          return child.get(*remainingArguments)
        end
      end
      return nil
    end
  end

  def getIndentation(level)
    return '  ' * level
  end

  def inspect(indentationLevel = 0)
    childString = ''
    @children.each do |child|
      childString += "\n"
      if child.class == Array
        childString += "#{getIndentation(indentationLevel + 1)}<array>"
      else
        childString += child.inspect(indentationLevel + 1)
      end
    end
    output = "#{getIndentation(indentationLevel)}#{@name} = #{@value.inspect}#{childString}"
    return output
  end
end
