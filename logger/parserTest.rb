require 'nil/file'

require_relative 'parser'

content = Nil.readFile('test/input.log')
root = parseBody(content)
puts root.inspect
