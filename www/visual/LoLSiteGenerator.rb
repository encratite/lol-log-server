require 'www-library/SiteGenerator'
require 'www-library/HTMLWriter'
require 'www-library/string'

class LoLSiteGenerator < WWWLib::SiteGenerator
  def render(request, content)
    writer = WWWLib::HTMLWriter.new
    writer.img(src: @site.getImage('background', 'top.jpg'), class: 'backgroundTop')
    writer.div(class: 'container') do
      writer.write(content)
    end
    #writer.img(src: @site.getImage('background', 'bottom.jpg'), class: 'backgroundBottm')
    return writer.output
  end
end
