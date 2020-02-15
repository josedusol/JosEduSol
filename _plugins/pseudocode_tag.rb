require 'csv'

module Jekyll
  class PseudocodeTag < Liquid::Block
    @@counter = 0
   
    def initialize(tag_name, input, tokens)
      super
      @input = input
    end

    def render(context)
      #Reading the tag parameters 
      input_split = CSV.parse_line(@input.strip, col_sep: " ") || []
      content = super
          
      pscode_id = ""
      if input_split.length > 0      
        pscode_id = "pscode_capt_" + input_split[0].to_s
      else   
        @@counter = @@counter + 1
        pscode_id = "pscode_nocapt_" + @@counter.to_s    
      end      
      
      output = "<pre id=\"#{pscode_id}\" class=\"algorithm-pscode\" style=\"display:hidden;\""  
      output += ">"   
      output += "\\begin{algorithm}"
      if input_split.length > 0      
        output += "\\caption{#{ input_split.length > 1 ? input_split[1] : ""}}"
      end
      output += "\\begin{algorithmic}"
      output += content
      output += "\\end{algorithmic}"
      output += "\\end{algorithm}"
      output += "</pre>"        
      output += "<script>"\
                  "pscode_config.captionCount = #{ input_split.length > 0 ? input_split[0].to_i - 1 : @@counter } ; "\
                  "pseudocode.renderElement(document.getElementById(\"#{pscode_id}\"), pscode_config);"\
                "</script>"

      return output
    end
  end
end

Liquid::Template.register_tag('pseudocode', Jekyll::PseudocodeTag)