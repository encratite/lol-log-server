require 'www-library/MIMEType'
require 'www-library/RequestManager'

def plainError(message)
  raise WWWLib::RequestManager::Exception.new([WWWLib::MIMEType::Plain, message])
end

def argumentError
  plainError 'Invalid argument.'
end
