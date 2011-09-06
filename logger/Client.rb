require 'nil/string'

require_relative 'GameResult'
require_relative 'parser'
require_relative 'date'

class Client
  ReadSize = 4 * 1024
  MaximumUnitSize = 100 * 1024
  MaximumLengthFieldSize = (Math.log(MaximumUnitSize) / Math.log(10)).ceil
  LengthFieldSeparator = ':'

  def initialize(client, database)
    @client = client
    @database = database
    addressArray = @client.peeraddr
    @port = addressArray[1]
    @address = addressArray[2]
    Thread.abort_on_exception = true
  end

  def print(line)
    puts "[#{@address}:#{@port}] #{line}"
  end

  def process
    print 'New connection'
    begin
      @buffer = ''
      while true
        data = @client.readpartial(ReadSize)
        if data.empty?
          print 'Disconnected'
          return
        end
        @buffer += data
        processBuffer
      end
    rescue EOFError => exception
      print 'Disconnected'
      return
    rescue => exception
      print "An exception of type #{exception.class} occurred: #{exception.message}"
      puts exception.backtrace.join("\n")
    end
    close
  end

  def close
    begin
      @client.close
    rescue SystemCallError, IOError, SocketError
    end
  end

  def processBuffer
    offset = @buffer.index(LengthFieldSeparator)
    if offset == nil
      #the length field has not been read yet
      if @buffer.size > MaximumUnitSize
        raise 'The packet size has been exceeded without having received the length field separator, disconnecting'
      end
      return
    end
    lengthField = @buffer[0..offset - 1]
    if !lengthField.isNumber
      raise 'Invalid length field specified'
      return
    end
    length = lengthField.to_i
    remainingContent = @buffer[offset + 1..-1]
    if remainingContent.size < length
      return
    end
    @buffer = remainingContent[length..-1]
    content = remainingContent[0..length - 1]
    print "Received end of game stats (#{content.size} bytes)"
    lines = content.split("\n")
    if lines.size < 4
      raise 'Invalid line count'
      return
    end
    utcOffsetInSeconds = lines[0].to_i
    precedingLine = lines[1]
    time = parseDate(precedingLine)
    if time == nil
      raise "Unable to parse time string: #{precedingLine.inspect}"
    end
    time -= utcOffsetInSeconds
    stats = lines[2..-1].join("\n")
    root = parseBody(stats)
    begin
      result = GameResult.new(time, stats, root)
      result.insertIntoDatabase(@database, @address)
    rescue RuntimeError => exception
      print "Result has been ignored due to an error: #{exception.message}"
    end
  end
end
