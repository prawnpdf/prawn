# encoding: utf-8
#
# generates outline dictionary and items for document
#
# Author Jonathan Greenberg

require 'forwardable'

module Prawn
  
  class Document

    # See Outline#define below for documentation
    def define_outline(&block)
      outline.define(&block)
    end

    # The Outline dictionary (12.3.3) for this document.  It is
    # lazily initialized, so that documents that do not have an outline
    # do not incur the additional overhead.
    def outline_root(outline_root)
      state.store.root.data[:Outlines] ||= ref!(outline_root)
    end

    # Lazily instantiates an Outline object for document. This is used as point of entry
    # to methods to build the outline tree.
    def outline
      @outline ||= Outline.new(self)
    end

  end
  
  # The Outline class organizes the outline tree items for the document.
  # Note that the prev and parent instance variables are adjusted while navigating 
  # through the nested blocks. These variables along with the presence or absense 
  # of blocks are the primary means by which the relations for the various
  # OutlineItems and the OutlineRoot are set. Unfortunately, the best way to
  # understand how this works is to follow the method calls through a real example.
  #
  # Some ideas for the organization of this class were gleaned from name_tree. In 
  # particular the way in which the OutlineItems are finally rendered into document 
  # objects in PdfObject through a hash.
  #
  class Outline
    
    extend Forwardable
    def_delegator :@document, :page_number
    
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
    
    # Defines an outline for the document.
    # The outline is an optional nested index that appears on the side of a PDF 
    # document usually with direct links to pages. The outline DSL is defined by nested 
    # blocks involving two methods: section and page.
    #
    # section(title, options{}, &block)
    #   title: the outline text that appears for the section.
    #   options: page - optional integer defining the page number for a destination link.
    #                 - currently only :FIT destination supported with link to top of page.
    #            closed - whether the section should show its nested outline elements.
    #                   - defaults to false.
    # page(page, options{})
    #   page: integer defining the page number for the destination link.
    #         currently only :FIT destination supported with link to top of page.
    #         set to nil if destination link is not desired.
    #   options: title - the outline text that appears for the section.
    #            closed - whether the section should show its nested outline elements.
    #                   - defaults to false.
    #
    # The syntax is best illustrated with an example:
    #
    # Prawn::Document.generate(outlined document) do
    #   text "Page 1. This is the first Chapter. "
    #   start_new_page
    #   text "Page 2. More in the first Chapter. "
    #   start_new_page
    #   define_outline do
    #     section 'Chapter 1', :page => 1, :closed => true do 
    #       page 1, :title => 'Page 1'
    #       page 2, :title => 'Page 2'
    #     end
    #   end
    # end
    # 
    # It should be noted that not defining a title for a page element will raise
    # a RequiredOption error
    #
    def define(&block)
      if block
        block.arity < 1 ? instance_eval(&block) : block[self]
      end
    end
     
    # Adds an outine section to the outline tree (see define_outline).
    # Although you will probably choose to exclusively use define_outline so 
    # that your outline tree is contained and easy to manage, this method
    # gives you the option to add sections to the outline tree at any point
    # during document generation. Note that the section will be added at the 
    # top level at the end of the outline. For more a more flexible API try
    # using outline.insert_section_after.
    #
    # block uses the same DSL syntax as define_outline, for example: 
    #
    #   outline.add_section do
    #     section 'Added Section', :page => 3 do
    #       page 3, :title => 'Page 3'
    #     end
    #   end
    def add_section(&block)
      @parent = outline_root
      @prev = outline_root.data.last
      if block
        block.arity < 1 ? instance_eval(&block) : block[self]
      end      
    end
    
    # Inserts an outline section to the outline tree (see define_outline).
    # Although you will probably choose to exclusively use define_outline so 
    # that your outline tree is contained and easy to manage, this method
    # gives you the option to insert sections to the outline tree at any point
    # during document generation. Unlike outline.add_section, this method allows 
    # you to enter a section after any other item at any level in the outline tree. 
    # Currently the only way to locate the place of entry is with the title for the 
    # item. If your titles names are not unique consider using define_outline.
    #
    # block uses the same DSL syntax as define_outline, for example: 
    # 
    #   go_to_page 2
    #   start_new_page
    #   text "Inserted Page"
    #   outline.insert_section_after :title => 'Page 2' do 
    #     page page_number, :title => "Inserted Page"
    #   end
    #
    def insert_section_after(title, &block)
      @prev = items[title]
      if @prev
        @parent = @prev.data.parent
        nxt = @prev.data.next
        if block
          block.arity < 1 ? instance_eval(&block) : block[self]
        end
        adjust_relations(nxt)
      else
        raise Prawn::Errors::UnknownOutlineTitle, 
          "\n No outline item with title: '#{title}' exists in the outline tree"
      end
    end

  private
    
    def section(title, options = {}, &block)
      add_outline_item(title, options, &block)
    end 
    
    def page(page = nil, options = {})
      if options[:title]
        title = options[:title] 
        options[:page] = page
      else
        raise Prawn::Errors::RequiredOption, 
          "\nTitle is a required option for page"
      end
      add_outline_item(title, options)
    end
     
    def add_outline_item(title, options, &block)
      outline_item = create_outline_item(title, options)
      set_relations(outline_item)
      increase_count
      set_variables_for_block(outline_item, block)
      block.call if block
      reset_parent(outline_item)
    end
    
    def create_outline_item(title, options)
      outline_item = OutlineItem.new(title, parent, options)

      if options[:page]
        page_index = options[:page] - 1
        outline_item.dest = [document.state.pages[page_index].dictionary, :Fit] 
      end

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
        @parent.data.last = nxt
      else 
        @parent.data.last = @prev
      end
    end
    
  end
  
  class OutlineRoot #:nodoc:
    attr_accessor :count, :first, :last
    
    def initialize
      @count = 0
    end
        
    def to_hash
      {:Type => :Outlines, :Count => count, :First => first, :Last => last}
    end
  end
  
  class OutlineItem #:nodoc:
    attr_accessor :count, :first, :last, :next, :prev, :parent, :title, :dest, :closed
  
    def initialize(title, parent, options)
      @closed = options[:closed]
      @title = title
      @parent = parent
      @count = 0
    end
  
    def to_hash
      hash = { :Title => Prawn::Core::LiteralString.new(title),
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
     
