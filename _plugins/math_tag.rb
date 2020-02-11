require 'csv'

module Jekyll
  class MathTag < Liquid::Block
    def initialize(tag_name, input, tokens)
      super
      @input = input
    end

    def render(context)
      #Reading the tag parameters 
      input_split = CSV.parse_line(@input.strip, col_sep: " ") 
      content = super

      output = "<div class=\"#{input_split[0]}\""            
      output += " id=\"#{input_split[0]}_#{input_split[1]}\" data-number=\"#{input_split[1]}\"" if input_split.length > 1
      output += " data-name=\" (#{input_split[2]})\""                                           if input_split.length > 2
      output += " markdown=\"block\">"
      output += content
      output += "</div>"
      
      return output  
    end
  end
end

Liquid::Template.register_tag('math', Jekyll::MathTag)