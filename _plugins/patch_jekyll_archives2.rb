require 'jekyll-archives'

module Jekyll
  module Archives
   
    module ArchivesExtensions     
      # "Clean" Monkey Patch on Jekyll-Archives to generate archives also for categories & tags 
      # from collection "notas"
      #
      # Working OK on Jekyll-Archives v2.2.1
      def tags
        notas = @site.collections["notas"].docs
        notas_by_tags = notas.group_by { |doc| doc.data["tags"] }
    
        ret = {}
        notas_by_tags.keys.each do |k| 
          k.each do |t|        
            ret.merge!({"#{t}" => notas_by_tags[k]}) {|key, oldval, newval| oldval + newval } 
          end
        end
        ret.merge!(@site.tags) {|key, oldval, newval| oldval + newval }   
      
        return ret
      end

      def categories
        notas = @site.collections["notas"].docs
        notas_by_cats = notas.group_by { |doc| doc.data["categories"] }
    
        ret = {}
        notas_by_cats.keys.each do |k| 
          k.each do |c|        
            ret.merge!({"#{c}" => notas_by_cats[k]}) {|key, oldval, newval| oldval + newval } 
          end
        end
        ret.merge!(@site.categories) {|key, oldval, newval| oldval + newval }   

        return ret           
      end
      
    end

    class Archives < Jekyll::Generator
      prepend ArchivesExtensions
    end  
 
  end
end    