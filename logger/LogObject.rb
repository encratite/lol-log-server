class LogObject
  attr_reader :name, :value, :children

  def initialize(name, value, children)
    @name = name
    @value = value
    @children = children
  end

  def get(*arguments)
    if arguments.empty?
      if @value.class == LogObjectType && @value.isArray
        return @children
      else
        return @value
      end
    else
      target = arguments.first
      remainingArguments = arguments[1..-1]
      @children.each do |child|
        if child.class != LogObject
          raise "Tried to look for #{arguments.inspect} in a non-LogObject (#{child.class})"
        end
        if child.name == target.to_s
          return child.get(*remainingArguments)
        end
      end
      raise "Unable to find symbol #{target.to_s.inspect}"
    end
  end

  def getIndentation(level)
    return '  ' * level
  end

  def inspect(indentationLevel = 0)
    childString = ''
    if value.class == LogObjectType && value.isArray
      childString += "\n#{getIndentation(indentationLevel + 1)}<array of size #{@children.size}>"
    else
      @children.each do |child|
        childString += "\n" + child.inspect(indentationLevel + 1)
      end
    end
    output = "#{getIndentation(indentationLevel)}#{@name} = #{@value.inspect}#{childString}"
    return output
  end
end
