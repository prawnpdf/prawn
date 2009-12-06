# encoding: utf-8
#
# generates outline dictionary and items for document
#
# Author Jonathan Greenberg
module Prawn
  class Document #:nodoc:
    module Outline
      def generate_outline(*outline)
        root_outline = ref!(:Type => :Outlines, :Count => 0)
        @store.root.data.merge!({:Outlines => root_outline})
        generate_child_items(root_outline, outline)
      end
      
      def generate_child_items(parent, child_items)
        prev = nil
        child_items.each_with_index do |item, index|
          item_array = has_children?(item) ? item.keys.first : item
          outline_item = {:Title => Prawn::LiteralString.new(item_array[0]), 
                          :Parent => parent, :Count => 0}
          outline_item.merge!(:Dest => [@store.pages.data[:Kids][item_array[1]], :Fit]) if item_array[1]
          outline_item.merge!({:Prev => prev}) if prev
          outline_item = ref!(outline_item)
          prev.data.merge!({:Next => outline_item}) if prev
          if index == 0 
            outline_item.data[:Parent].data.merge!({:First => outline_item})
          end
          if index == child_items.count - 1
            outline_item.data[:Parent].data.merge!({:Last => outline_item})
          end
          outline_item.data[:Parent].data[:Count] += 1
          prev = outline_item
          generate_child_items(outline_item, item.values.first) if has_children?(item)
        end
      end  
      
      def has_children?(item)
        item.is_a? Hash
      end
      
    end
  end
end
     
