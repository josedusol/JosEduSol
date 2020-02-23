require 'csv'

module Jekyll
  class PseudocodeTag < Liquid::Block
    @@counter = 0
   
    def initialize(tag_name, input, tokens)
      super
      @input = input
    end

    def render(context)
      content    = super
      pscode_id  = ""
      fst_params = []
      snd_params = ""
      pscode_config = { "indentSize"       => "1.2em", 
                        "commentDelimiter" => "//", 
                        "lineNumber"       => true,
                        "lineNumberPunc"   => ".", 
                        "noEnd"            => true,
                        "captionCount"     => :undefined,
                        "title"            => "Algoritmo" }
      
      #Reading the tag parameters 
      input_split = @input.split("|")     
      if (input_split.length == 0) 
        @@counter = @@counter + 1
        pscode_id = "pscode_nocapt_" + @@counter.to_s    
        pscode_config["captionCount"] = @@counter
      elsif (input_split.length > 0)
        if not input_split[0].strip.empty?
          fst_params = CSV.parse_line(input_split[0].strip, col_sep: " ")   
          pscode_id = "pscode_capt_" + fst_params[0].to_s
          pscode_config["captionCount"] = fst_params[0].to_i - 1 
        else  
          @@counter = @@counter + 1
          pscode_id = "pscode_nocapt_" + @@counter.to_s    
          pscode_config["captionCount"] = @@counter
        end          
      end
      if (input_split.length > 1 and not input_split[1].strip.empty?)   
        snd_params = JSON.parse(input_split[1].strip)
        pscode_config.merge!(snd_params)
      end         
      
      output = "<pre id=\"#{pscode_id}\" class=\"algorithm-pscode\" style=\"display:hidden;\""  
      output += ">"   
      output += "\\begin{algorithm}"
      if fst_params.length > 0
        output += "\\caption{#{ fst_params.length > 1 ? fst_params[1] : ""}}"
      end
      output += "\\begin{algorithmic}"
      output += content
      output += "\\end{algorithmic}"
      output += "\\end{algorithm}"
      output += "</pre>"        
      output += "<script>"\
                  "var ele = pseudocode.renderElement(document.getElementById('#{pscode_id}'), #{to_js(pscode_config)});"\
                "</script>"

      return output
    end
    
    def to_js(json)
      ret = "{"
      json.each_with_index do |(key, value), index|
        ret += "#{key}:#{ value.kind_of?(String) ? "'"+value+"'" : value },"
      end
      return ret + "}"
    end
  end
end

Liquid::Template.register_tag('pseudocode', Jekyll::PseudocodeTag)