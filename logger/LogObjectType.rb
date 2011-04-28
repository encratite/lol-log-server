class LogObjectType
  attr_reader :type

  def initialize(type)
    @type = type
  end

  def inspect
    return "<type: #{@type}>"
  end

  def isArray
    return type == 'Array'
  end
end
