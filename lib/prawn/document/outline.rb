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
    attr_accessor :items
    
    def initialize(document)
      @document = document
      @outline_root = document.outline_root(OutlineRoot.new)
      @parent = outline_root
      @prev = nil
      @items = {}
    end
    
    def generate_outline(&block)
      if block
        block.arity < 1 ? instance_eval(&block) : block[self]
      end
    end
    
    def add_section(&block)
      @parent = outline_root
      @prev = outline_root.data.last
      if block
        block.arity < 1 ? instance_eval(&block) : block[self]
      end      
    end
    
    def insert_section_after(options = {}, &block)
      @prev = items[options[:title]]
      @parent = @prev.data.parent
      nxt = @prev.data.next
      if block
        block.arity < 1 ? instance_eval(&block) : block[self]
      end
      adjust_relations(nxt)
    end
    
    def method_missing(method,*args,&block) 
      return document.send(method)
      super 
    end 

  private
    
    def section(title, options = {}, &block)
      outline_item = create_outline_item(title, options)
      set_relations(outline_item)
      increase_count
      set_variables_for_block(outline_item, block)
      block.call if block
      reset_parent(outline_item)
    end 
    
    alias :page :section
    
    def create_outline_item(title, options)
      outline_item = OutlineItem.new(title, parent, options)
      outline_item.dest = [document.page_identifier(options[:page]), :Fit] if options[:page]
      outline_item.prev = prev if @prev
      items[title] = document.ref!(outline_item)
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
    
    def adjust_relations(nxt)
      if nxt 
        nxt.data.prev = @prev
        @prev.data.next = nxt
      else 
        @parent.data.last = @prev
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
    attr_accessor :count, :first, :last, :next, :prev, :parent, :title, :dest, :closed
  
    def initialize(title, parent, options)
      @closed = options[:closed]
      @title = title
      @parent = parent
      @count = 0
    end
  
    def to_hash
      hash = { :Title => Prawn::LiteralString.new(title),
               :Parent => parent,
               :Count => closed ? -count : count }
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
     
