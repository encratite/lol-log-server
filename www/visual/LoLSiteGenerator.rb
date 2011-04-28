require 'www-library/SiteGenerator'
require 'www-library/HTMLWriter'
require 'www-library/string'

class LoLSiteGenerator < WWWLib::SiteGenerator
  def render(title, request, content)
    writer = WWWLib::HTMLWriter.new
    writer.div(class: 'center') do
      writer.div do
        writer.img(src: @site.getImage('logo.jpg'), alt: Name)
      end
      request.handler.getMenu.each do |menuLevel|
        writer.ul(id: 'menu') do
          menuLevel.each do |item|
            writer.li do
              writer.a(href: WWWLib.slashify(item.path)) do
                item.description
              end
            end
          end
        end
      end
      writer.div(class: 'container') do
        if title == nil
          writer.h1 do
            request.handler.menuDescription
          end
        end
        content
      end
    end
    return writer.output
  end
end
