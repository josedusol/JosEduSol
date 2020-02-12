module Jekyll
  module Drops
    class UrlDrop < Drop
    
      # Monkey Patch to return categories names as slug
      # instead of strings
      #
      # An url for a post with category "category with space" will be in
      # slugified form : /category-with-space
      # instead of url encoded form : /category%20with%20space
      #
      # @see utils.slugify
      def categories
        category_set = Set.new
        Array(@obj.data["categories"]).each do |category|
          category_set << Utils.slugify(category.to_s, mode: "latin", cased: false)
        end
        category_set.to_a.join("/")
      end   
    end
  end
end    