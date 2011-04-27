require 'nil/string'

class Client
  ReadSize = 4 * 1024
  MaximumPacketSize = 100 * 1024
  MaximumLengthFieldSize = (Math.log(MaximumPacketSize) / Math.log(10)).ceil
  LengthFieldSeparator = ':'

  def initialize(client)
    @client = client
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
    rescue => exception
      print "An exception occurred: #{exception.message}"
    end
    close
  end

  def close
    begin
      @client.close
    rescue SystemCallError, IOError, SocketError => exception
    end
  end

  def processBuffer
    offset = @buffer.index(LengthFieldSeparator)
    if offset == nil
      #the length field has not been read yet
      if @buffer.size > MaximumPacketSize
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
  end
end
