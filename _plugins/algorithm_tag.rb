require 'csv'

module Jekyll
  class AlgorithmTag < Liquid::Block
    def initialize(tag_name, input, tokens)
      super
      @input = input
    end

    def render(context)
      #Reading the tag parameters 
      input_split = CSV.parse_line(@input.strip, col_sep: " ") || []
      content = super

      output = "<div class=\"algorithm-pscode\""     
      output += " id=\"algorithm_#{input_split[0] || ""}\""
      output += ">"
      output += "\\begin{algorithm}"
      if input_split.length > 0      
        output += "\\caption{#{ input_split.length > 1 ? input_split[1] : ""}}"
      end
      output += "\\begin{algorithmic}"
      output += content
      output += "\\end{algorithmic}"
      output += "\\end{algorithm}"
      output += "</div>"
      output += "<script>"\
                  "var parentEl = document.getElementById(\"algorithm_#{input_split[0] || ""}\");"\
                  "var code = parentEl.textContent;"\
                  "parentEl.innerHTML = '';"\
                  "pseudocode.render(code, parentEl, pscode_config);"\
                "</script>"
                
      return output
    end
  end
end

Liquid::Template.register_tag('algorithm', Jekyll::AlgorithmTag)