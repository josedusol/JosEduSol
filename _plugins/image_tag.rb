class MyImageTag < Liquid::Tag
  def initialize(tag_name, input, tokens)
    super
    @input = input
  end

  def render(context)

    # Reading the tag parameters
    input_split = split_params(@input) 
    image_name = input_split[0].strip.downcase
    data = ""
    if( input_split.length > 1 )
      data = to_html(JSON.parse(input_split[1].strip))
    end    
    
    # Accessing the page/site variables
    baseurl = context.environments.first["site"]["baseurl"]
    post_title = File.basename(context.environments.first['page']['url'])
    
    # Create the HTML output for the image container   
    output = "<img src=\"#{baseurl}/assets/images/#{post_title}/#{image_name}\" #{data}>"

    return output  
  end
  
  def split_params(params)
    params.split("|")
  end
  
  def to_html(json)
    ret = ""
    json.each_with_index do |(key, value), index|
      ret += "#{key}=\"#{value}\""
    end
    return ret
  end
end

Liquid::Template.register_tag('img', MyImageTag)