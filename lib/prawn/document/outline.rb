# encoding: utf-8
#
# generates outline dictionary and items for document
#
# Author Jonathan Greenberg
module Prawn
  class Document #:nodoc:
    module Outline
      
      attr_accessor :parent
      attr_accessor :prev
      
      def generate_outline(&block)
        root_outline = ref!(:Type => :Outlines, :Count => 0)
        @store.root.data.merge!({:Outlines => root_outline})
        @parent = root_outline
        @prev = nil
        block.call if block
      end
  
  private
      
      def section(item_array, &block)
        outline_item = create_outline_item(item_array)
        set_relations(outline_item)
        increase_count
        set_variables_for_block(outline_item, block)
        block.call if block
        reset_parent(outline_item)
      end 
      
      alias :page :section
      
      def create_outline_item(item_array)
        outline_item = {:Title => Prawn::LiteralString.new(item_array[0]), 
                          :Parent => parent, :Count => 0}
        outline_item.merge!(:Dest => [@store.pages.data[:Kids][item_array[1]], 
                            :Fit]) if item_array[1]
        outline_item.merge!({:Prev => prev}) if prev
        outline_item = ref!(outline_item)
      end
      
      def set_relations(outline_item)
        prev.data.merge!({:Next => outline_item}) if prev
        parent.data.merge!({:First => outline_item}) unless prev
        parent.data.merge!({:Last => outline_item})
      end
      
      def increase_count
        counting_parent = parent
        while counting_parent 
          counting_parent.data[:Count] += 1
          counting_parent = counting_parent.data[:Parent]
        end
      end
      
      def set_variables_for_block(outline_item, block)
        @prev = block ? nil : outline_item
        @parent = outline_item if block
      end
      
      def reset_parent(outline_item)
        if parent == outline_item
          @prev = outline_item
          @parent = outline_item.data[:Parent]
        end
      end
      
    end
  end
end
     
