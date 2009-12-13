# encoding: utf-8
#
# generates outline dictionary and items for document
#
# Author Jonathan Greenberg
module Prawn
  class Outline
    
    attr_accessor :parent
    attr_accessor :prev
    attr_accessor :document
    attr_accessor :outline_root
    
    def initialize(document)
      @document = document
      @outline_root = document.outline(OutlineRoot.new)
      @parent = outline_root
      @prev = nil
    end
    
    def generate_outline(&block)
      if block
        block.arity < 1 ? instance_eval(&block) : block[self]
      end
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
      outline_item = OutlineItem.new(item_array[0], parent)
      outline_item.dest = [document.page_identifier(item_array[1]), :Fit] if item_array[1]
      outline_item.prev if prev
      document.ref!(outline_item)
    end
    
    def set_relations(outline_item)
      prev.data.next = outline_item if prev
      parent.data.first = outline_item unless prev
      parent.data.last = outline_item
    end
    
    def increase_count
      counting_parent = parent
      while counting_parent
        counting_parent.data.count += 1
        if counting_parent == outline_root
          counting_parent = nil
        else
          counting_parent = counting_parent.data.parent
        end
      end
    end
    
    def set_variables_for_block(outline_item, block)
      self.prev = block ? nil : outline_item
      self.parent = outline_item if block
    end
    
    def reset_parent(outline_item)
      if parent == outline_item
        self.prev = outline_item
        self.parent = outline_item.data.parent
      end
    end
  end
  
  class OutlineRoot
    attr_accessor :count, :first, :last
    
    def initialize
      @count = 0
    end
        
    def to_hash
      {:Type => :Outlines, :Count => count, :First => first, :Last => last}
    end
  end
  
  class OutlineItem
    attr_accessor :count, :first, :last, :next, :prev, :parent, :title, :dest
  
    def initialize(title, parent)
      @title = title
      @parent = parent
      @count = 0
    end
  
    def to_hash
      hash = { :Title => Prawn::LiteralString.new(title),
               :Parent => parent,
               :Count => count }
      [{:First => first}, {:Last => last}, {:Next => @next}, 
       {:Prev => prev}, {:Dest => dest}].each do |h|
        unless h.values.first.nil?
          hash.merge!(h)
        end
      end
      hash 
    end
  end    
end
     
