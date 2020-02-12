require 'jekyll-archives'

module Jekyll
  module Archives
   
    module ArchiveExtensions     
      # "Clean" Monkey Patch on Jekyll-Archives to generate category/tag pages without non-ascii characters
      #
      # For example, for category "Esto y más" the path should be 
      #    "/esto-y-mas/" 
      # and not
      #    "/esto-y-más/"
      def initialize(site, title, type, posts)
        @site   = site
        @posts  = posts
        @type   = type
        @title  = title
        @config = site.config["jekyll-archives"]

        # PATCH: Use mode "latin" here
        @slug = Utils.slugify(title, mode: "latin", cased: false) if title.is_a? String

        @ext  = File.extname(relative_path)
        @path = relative_path
        @name = File.basename(relative_path, @ext)

        @data = {
          "layout" => layout,
        }
        @content = ""
      end
    end

    class Archive < Jekyll::Page
      prepend ArchiveExtensions
    end  
 
  end
end    