class Timer
  def initialize
    @lastTimestamp = Time.now
  end

  def getDuration
    now = Time.now
    difference = now - @lastTimestamp
    @lastTimestamp = now
    return difference
  end

  def print
    duration = getDuration
    begin
      raise nil
    rescue Exception => exception
      origin = exception.backtrace[2]
      puts "[#{duration} s] #{origin}"
    end
  end
end
