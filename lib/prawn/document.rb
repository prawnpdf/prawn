# encoding: utf-8

# document.rb : Implements PDF document generation for Prawn
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require "stringio"
require "prawn/document/page_geometry" 
require "prawn/document/bounding_box"
require "prawn/document/internals"
require "prawn/document/span"
require "prawn/document/text"
require "prawn/document/annotations"
require "prawn/document/destinations"

module Prawn
  class Document  
           
    include Text                             
    include PageGeometry  
    include Internals
    include Annotations
    include Destinations
    include Prawn::Graphics    
    include Prawn::Images

    attr_accessor :y, :margin_box
    attr_reader   :margins, :page_size, :page_layout
    attr_writer   :font_size
      
    # Creates and renders a PDF document. 
    #
    # When using the implicit block form, Prawn will evaluate the block
    # within an instance of Prawn::Document, simplifying your syntax.
    # However, please note that you will not be able to reference variables
    # from the enclosing scope within this block.
    #
    #   # Using implicit block form and rendering to a file
    #   Prawn::Document.generate "foo.pdf" do
    #     font "Times-Roman"   
    #     text "Hello World", :at => [200,720], :size => 32       
    #   end
    #
    # If you need to access your local and instance variables, use the explicit
    # block form shown below.  In this case, Prawn yields an instance of
    # PDF::Document and the block is an ordinary closure:     
    #
    #   # Using explicit block form and rendering to a file   
    #   content = "Hello World"
    #   Prawn::Document.generate "foo.pdf" do |pdf|
    #     pdf.font "Times-Roman"
    #     pdf.text content, :at => [200,720], :size => 32
    #   end                                                
    #
    def self.generate(filename,options={},&block)
      pdf = new(options,&block)          
      pdf.render_file(filename)
    end
          
    # Creates a new PDF Document.  The following options are available:
    #
    # <tt>:page_size</tt>:: One of the Document::PageGeometry::SIZES [LETTER]
    # <tt>:page_layout</tt>:: Either <tt>:portrait</tt> or <tt>:landscape</tt>
    # <tt>:left_margin</tt>:: Sets the left margin in points [ 0.5 inch]
    # <tt>:right_margin</tt>:: Sets the right margin in points [ 0.5 inch]
    # <tt>:top_margin</tt>:: Sets the top margin in points [ 0.5 inch]
    # <tt>:bottom_margin</tt>:: Sets the bottom margin in points [0.5 inch]
    # <tt>:skip_page_creation</tt>:: Creates a document without starting the first page [false]
    # <tt>:compress</tt>:: Compresses content streams before rendering them [false]
    # <tt>:background</tt>:: An image path to be used as background on all pages [nil]
    # 
    # Usage:
    #                             
    #   # New document, US Letter paper, portrait orientation
    #   pdf = Prawn::Document.new                            
    #
    #   # New document, A4 paper, landscaped
    #   pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)    
    #
    #   # New document, with background
    #   pdf = Prawn::Document.new(:background => "#{Prawn::BASEDIR}/data/images/pigs.jpg")    
    #
    def initialize(options={},&block)   
       Prawn.verify_options [:page_size, :page_layout, :left_margin, 
         :right_margin, :top_margin, :bottom_margin, :skip_page_creation, 
         :compress, :skip_encoding, :text_options, :background ], options
         
       @objects = []
       @info    = ref(:Creator => "Prawn", :Producer => "Prawn")
       @pages   = ref(:Type => :Pages, :Count => 0, :Kids => [])
       @root    = ref(:Type => :Catalog, :Pages => @pages)
       @page_size       = options[:page_size]   || "LETTER"    
       @page_layout     = options[:page_layout] || :portrait
       @compress        = options[:compress] || false                
       @skip_encoding   = options[:skip_encoding]
       @background      = options[:background]
       @font_size       = 12
       
       text_options.update(options[:text_options] || {}) 
             
       @margins = { :left   => options[:left_margin]   || 36,
                    :right  => options[:right_margin]  || 36,  
                    :top    => options[:top_margin]    || 36,       
                    :bottom => options[:bottom_margin] || 36  }
        
       generate_margin_box
       
       @bounding_box = @margin_box
       
       start_new_page unless options[:skip_page_creation]    
       
       if block
         block.arity < 1 ? instance_eval(&block) : block[self]    
       end 
     end     
            
     # Creates and advances to a new page in the document. 
     #
     # Page size, margins, and layout can also be set when generating a
     # new page. These values will become the new defaults for page creation
     #
     #   pdf.start_new_page(:size => "LEGAL", :layout => :landscape)    
     #   pdf.start_new_page(:left_margin => 50, :right_margin => 50)
     #                                
     def start_new_page(options = {})      
       @page_size   = options[:size] if options[:size]
       @page_layout = options[:layout] if options[:layout]
                                             
       [:left,:right,:top,:bottom].each do |side|  
         if options[:"#{side}_margin"] 
           @margins[side] = options[:"#{side}_margin"]   
         end
       end
       
       finish_page_content if @page_content  
       build_new_page_content

       @pages.data[:Kids] << @current_page
       @pages.data[:Count] += 1 
     
       add_content "q"   
       
       @y = @bounding_box.absolute_top
       
       image(@background, :at => [0,@y]) if @background
    end             
      
    # Returns the number of pages in the document
    #  
    #   pdf = Prawn::Document.new
    #   pdf.page_count #=> 1
    #   3.times { pdf.start_new_page }
    #   pdf.page_count #=> 4
    #
    def page_count
      @pages.data[:Count]
    end
    
    # The current y drawing position relative to the innermost bounding box,
    # or to the page margins at the top level.  
    #
    def cursor
      y - bounds.absolute_bottom
    end
       
    # Renders the PDF document to string
    #
    def render
      output = StringIO.new
      finish_page_content

      render_header(output)
      render_body(output)
      render_xref(output)
      render_trailer(output)
      str = output.string 
      str.force_encoding("ASCII-8BIT") if str.respond_to?(:force_encoding)
      str
    end
     
    # Renders the PDF document to file.
    #
    #   pdf.render_file "foo.pdf"     
    #
    def render_file(filename)
      Kernel.const_defined?("Encoding") ? mode = "wb:ASCII-8BIT" : mode = "wb"
      File.open(filename,mode) { |f| f << render }
    end   
    
    # Returns the current BoundingBox object, which is by default
    # the box represented by the margin box.  When called from within
    # a <tt>bounding_box</tt> block, the box defined by that call will
    # be used.
    #
    def bounds
      @bounding_box
    end  
      
    # Sets Document#bounds to the BoundingBox provided.  If you don't know
    # why you'd need to do this, chances are, you can ignore this feature
    #
    def bounds=(bounding_box)
      @bounding_box = bounding_box
    end

    # Moves up the document by n points
    # 
    def move_up(n)
      self.y += n
    end

    # Moves down the document by n point
    # 
    def move_down(n)
      self.y -= n
    end
 
    # Moves down the document and then executes a block.
    #
    #   pdf.text "some text"
    #   pdf.pad_top(100) do
    #     pdf.text "This is 100 points below the previous line of text"
    #   end
    #   pdf.text "This text appears right below the previous line of text"
    #
    def pad_top(y)
      move_down(y)
      yield
    end

    # Executes a block then moves down the document
    #
    #   pdf.text "some text"
    #   pdf.pad_bottom(100) do
    #     pdf.text "This text appears right below the previous line of text"
    #   end
    #   pdf.text "This is 100 points below the previous line of text"
    #
    def pad_bottom(y)
      yield
      move_down(y)
    end

    # Moves down the document by y, executes a block, then moves down the
    # document by y again.
    #
    #   pdf.text "some text"
    #   pdf.pad(100) do
    #     pdf.text "This is 100 points below the previous line of text"  
    #   end
    #   pdf.text "This is 100 points below the previous line of text"
    #
    def pad(y)
      move_down(y)
      yield
      move_down(y)
    end

    def mask(*fields) # :nodoc:
     # Stores the current state of the named attributes, executes the block, and
     # then restores the original values after the block has executed.
     # -- I will remove the nodoc if/when this feature is a little less hacky
      stored = {}
      fields.each { |f| stored[f] = send(f) }
      yield
      fields.each { |f| send("#{f}=", stored[f]) }
    end
     
    # Returns true if content streams will be compressed before rendering,
    # false otherwise
    #
    def compression_enabled?
      !!@compress
    end 
   
    private 
    
    # See Prawn::Document::Internals for low-level PDF functions       
    
    def build_new_page_content
      generate_margin_box    
      @page_content = ref(:Length => 0)   
    
      @current_page = ref(:Type      => :Page, 
                          :Parent    => @pages, 
                          :MediaBox  => page_dimensions, 
                          :Contents  => @page_content)
      update_colors
    end
    
    def generate_margin_box     
      old_margin_box = @margin_box
      @margin_box = BoundingBox.new(
        self,
        [ @margins[:left], page_dimensions[-1] - @margins[:top] ] ,
        :width => page_dimensions[-2] - (@margins[:left] + @margins[:right]),
        :height => page_dimensions[-1] - (@margins[:top] + @margins[:bottom])
      )                                 
            
      # update bounding box if not flowing from the previous page
      # FIXME: This may have a bug where the old margin is restored
      # when the bounding box exits.
      @bounding_box = @margin_box if old_margin_box == @bounding_box              
    end
    
  end
end
