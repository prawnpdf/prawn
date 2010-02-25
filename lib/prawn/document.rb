# encoding: utf-8

# document.rb : Implements PDF document generation for Prawn
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require "stringio"
require "prawn/document/page_geometry"
require "prawn/document/bounding_box"
require "prawn/document/column_box"
require "prawn/document/internals"
require "prawn/document/span"
require "prawn/document/annotations"
require "prawn/document/destinations"
require "prawn/document/snapshot"
require "prawn/document/graphics_state"

module Prawn
  
  # The Prawn::Document class is how you start creating a PDF document.
  # 
  # There are three basic ways you can instantiate PDF Documents in Prawn, they 
  # are through assignment, implicit block or explicit block.  Below is an exmple
  # of each type, each example does exactly the same thing, makes a PDF document
  # with all the defaults and puts in the default font "Hello There" and then
  # saves it to the current directory as "example.pdf"
  # 
  # For example, assignment can be like this:
  # 
  #   pdf = Prawn::Document.new
  #   pdf.text "Hello There"
  #   pdf.render_file "example.pdf"
  # 
  # Or you can do an implied block form:
  #   
  #   Prawn::Document.generate "example.pdf" do
  #     text "Hello There"
  #   end
  # 
  # Or if you need to access a variable outside the scope of the block, the
  # explicit block form:
  # 
  #   words = "Hello There"
  #   Prawn::Document.generate "example.pdf" do |pdf|
  #     pdf.text words
  #   end
  #
  # Usually, the block forms are used when you are simply creating a PDF document
  # that you want to immediately save or render out.
  # 
  # See the new and generate methods for further details on the above.
  #
  class Document

    include Internals
    include Annotations
    include Destinations
    include Snapshot
    include GraphicsState
    include Prawn::Text
    include Prawn::Graphics
    include Prawn::Images
    include Prawn::Stamp
    

    attr_accessor :margin_box, :page
    attr_reader   :margins, :y, :store, :pages
    attr_writer   :font_size
    attr_accessor :default_line_wrap


    # Any module added to this array will be included into instances of
    # Prawn::Document at the per-object level.  These will also be inherited by
    # any subclasses.
    #
    # Example:
    #
    #   module MyFancyModule
    #    
    #     def party!
    #       text "It's a big party!"
    #     end
    #   
    #   end
    #
    #   Prawn::Document.extensions << MyFancyModule
    #
    #   Prawn::Document.generate("foo.pdf") do
    #     party!
    #   end
    #
    def self.extensions
      @extensions ||= []
    end

    def self.inherited(base) #:nodoc:
      extensions.each { |e| base.extensions << e }
    end

    # Creates and renders a PDF document.
    #
    # When using the implicit block form, Prawn will evaluate the block
    # within an instance of Prawn::Document, simplifying your syntax.
    # However, please note that you will not be able to reference variables
    # from the enclosing scope within this block.
    #
    #   # Using implicit block form and rendering to a file
    #   Prawn::Document.generate "example.pdf" do
    #     # self here is set to the newly instantiated Prawn::Document
    #     # and so any variables in the outside scope are unavailable
    #     font "Times-Roman"
    #     draw_text "Hello World", :at => [200,720], :size => 32
    #   end
    #
    # If you need to access your local and instance variables, use the explicit
    # block form shown below.  In this case, Prawn yields an instance of
    # PDF::Document and the block is an ordinary closure:
    #
    #   # Using explicit block form and rendering to a file
    #   content = "Hello World"
    #   Prawn::Document.generate "example.pdf" do |pdf|
    #     # self here is left alone
    #     pdf.font "Times-Roman"
    #     pdf.draw_text content, :at => [200,720], :size => 32
    #   end
    #
    def self.generate(filename,options={},&block)
      pdf = new(options,&block)
      pdf.render_file(filename)
    end

    # Creates a new PDF Document.  The following options are available (with
    # the default values marked in [])
    #
    # <tt>:page_size</tt>:: One of the Document::PageGeometry sizes [LETTER]
    # <tt>:page_layout</tt>:: Either <tt>:portrait</tt> or <tt>:landscape</tt>
    # <tt>:margin</tt>:: Sets the margin on all sides in points [0.5 inch]
    # <tt>:left_margin</tt>:: Sets the left margin in points [0.5 inch]
    # <tt>:right_margin</tt>:: Sets the right margin in points [0.5 inch]
    # <tt>:top_margin</tt>:: Sets the top margin in points [0.5 inch]
    # <tt>:bottom_margin</tt>:: Sets the bottom margin in points [0.5 inch]
    # <tt>:skip_page_creation</tt>:: Creates a document without starting the first page [false]
    # <tt>:compress</tt>:: Compresses content streams before rendering them [false]
    # <tt>:optimize_objects</tt>:: Reduce number of PDF objects in output, at expense of render time [false]
    # <tt>:background</tt>:: An image path to be used as background on all pages [nil]
    # <tt>:info</tt>:: Generic hash allowing for custom metadata properties [nil]
    # <tt>:text_options</tt>:: A set of default options to be handed to text(). Be careful with this.
    #
    # Setting e.g. the :margin to 100 points and the :left_margin to 50 will result in margins
    # of 100 points on every side except for the left, where it will be 50.
    #
    # The :margin can also be an array much like CSS shorthand:
    #
    #   # Top and bottom are 20, left and right are 100.
    #   :margin => [20, 100]
    #   # Top is 50, left and right are 100, bottom is 20.
    #   :margin => [50, 100, 20]
    #   # Top is 10, right is 20, bottom is 30, left is 40.
    #   :margin => [10, 20, 30, 40]
    #
    # Additionally, :page_size can be specified as a simple two value array giving
    # the width and height of the document you need in PDF Points.
    # 
    # Usage:
    #
    #   # New document, US Letter paper, portrait orientation
    #   pdf = Prawn::Document.new
    #
    #   # New document, A4 paper, landscaped
    #   pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    #
    #   # New document, Custom size
    #   pdf = Prawn::Document.new(:page_size => [200, 300])
    #
    #   # New document, with background
    #   pdf = Prawn::Document.new(:background => "#{Prawn::BASEDIR}/data/images/pigs.jpg")
    #
    def initialize(options={},&block)   
       Prawn.verify_options [:page_size, :page_layout, :margin, :left_margin, 
         :right_margin, :top_margin, :bottom_margin, :skip_page_creation, 
         :compress, :skip_encoding, :text_options, :background, :info,
         :optimize_objects], options


       # need to fix, as the refactoring breaks this
       # raise NotImplementedError if options[:skip_page_creation]

       self.class.extensions.reverse_each { |e| extend e }
      
       options[:info] ||= {}
       options[:info][:Creator] ||= "Prawn"
       options[:info][:Producer] = "Prawn"

       options[:info].keys.each do |key|
         if options[:info][key].kind_of?(String)
           options[:info][key] = Prawn::LiteralString.new(options[:info][key])
         end
       end
          
       @version = 1.3
       @store = Prawn::Core::ObjectStore.new(options[:info])
       @trailer = {}

       @before_render_callbacks = []
       @on_page_create_callback = nil

       @compress         = options[:compress] || false
       @optimize_objects = options.fetch(:optimize_objects, false)
       @skip_encoding    = options[:skip_encoding]
       @background       = options[:background]
       @font_size        = 12

       @pages            = []
       @page             = nil

       @bounding_box  = nil
       @margin_box    = nil

       @text_options = options[:text_options] || {}
       @default_line_wrap = Prawn::Text::LineWrap.new

       @page_number = 0

       options[:size] = options.delete(:page_size)
       options[:layout] = options.delete(:page_layout)

       if options[:skip_page_creation]
         start_new_page(options.merge(:orphan => true))
       else
         start_new_page(options)
       end
       
       @bounding_box = @margin_box
       
       if block
         block.arity < 1 ? instance_eval(&block) : block[self]
       end
     end

     # Creates and advances to a new page in the document.
     #
     # Page size, margins, and layout can also be set when generating a
     # new page. These values will become the new defaults for page creation
     #
     #   pdf.start_new_page #=> Starts new page keeping current values
     #   pdf.start_new_page(:size => "LEGAL", :layout => :landscape)
     #   pdf.start_new_page(:left_margin => 50, :right_margin => 50)
     #   pdf.start_new_page(:margin => 100)
     #
     def start_new_page(options = {})
       if last_page = page
         last_page_size    = last_page.size
         last_page_layout  = last_page.layout
         last_page_margins = last_page.margins
       end

       self.page = Prawn::Core::Page.new(self, 
         :size    => options[:size]   || last_page_size, 
         :layout  => options[:layout] || last_page_layout,
         :margins => last_page_margins )
  
       
       apply_margin_option(options) if options[:margin]

       [:left,:right,:top,:bottom].each do |side|
         if margin = options[:"#{side}_margin"]
           page.margins[side] = margin
         end
       end

       generate_margin_box

       update_colors
       undash if dashed?
      
       unless options[:orphan]
         pages.insert(@page_number, page)
         @store.pages.data[:Kids].insert(@page_number, page.dictionary)
         @store.pages.data[:Count] += 1
         @page_number += 1

         save_graphics_state
        
         canvas { image(@background, :at => bounds.top_left) } if @background 
         @y = @bounding_box.absolute_top

         float do
           @on_page_create_callback.call(self) if @on_page_create_callback 
         end
       end
    end

    # Returns the number of pages in the document
    #
    #   pdf = Prawn::Document.new
    #   pdf.page_count #=> 1
    #   3.times { pdf.start_new_page }
    #   pdf.page_count #=> 4
    #
    def page_count
      pages.length
    end

    # Returns the 1-based page number of the current page. Returns 0 if the
    # document has no pages.
    #
    def page_number
      @page_number
    end
    
    # Re-opens the page with the given (1-based) page number so that you can
    # draw on it. Does not restore page state such as margins, page orientation,
    # or paper size, so you'll have to handle that yourself.
    #
    # See Prawn::Document#number_pages for a sample usage of this capability.
    #
    def go_to_page(k)
      @page_number = k
      self.page = pages[k-1]
    end

    def y=(new_y)
      @y = new_y
      bounds.update_height
    end

    # The current y drawing position relative to the innermost bounding box,
    # or to the page margins at the top level.
    #
    def cursor
      y - bounds.absolute_bottom
    end


    # Moves to the specified y position in relative terms to the bottom margin.
    # 
    def move_cursor_to(new_y)
      self.y = new_y + bounds.absolute_bottom
    end

    # Executes a block and then restores the original y position
    #
    #   pdf.text "A"
    #
    #   pdf.float do
    #     pdf.move_down 100
    #     pdf.text "C"
    #   end
    #
    #   pdf.text "B" 
    #   
    def float 
      mask(:y) { yield }
    end

    # Renders the PDF document to string
    #
    def render
      output = StringIO.new
      finalize_all_page_contents

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

    # The bounds method returns the current bounding box you are currently in,
    # which is by default the box represented by the margin box on the
    # document itself.  When called from within a created <tt>bounding_box</tt>
    # block, the box defined by that call will be returned instead of the
    # document margin box.
    #
    # Another important point about bounding boxes is that all x and y measurements
    # within a bounding box code block are relative to the bottom left corner of the
    # bounding box.
    # 
    # For example:
    # 
    #  Prawn::Document.new do
    #    # In the default "margin box" of a Prawn document of 0.5in along each edge
    #    
    #    # Draw a border around the page (the manual way)
    #    stroke do
    #      line(bounds.bottom_left, bounds.bottom_right)
    #      line(bounds.bottom_right, bounds.top_right)
    #      line(bounds.top_right, bounds.top_left)
    #      line(bounds.top_left, bounds.bottom_left)
    #    end
    # 
    #    # Draw a border around the page (the easy way)
    #    stroke_bounds
    #  end
    # 
    def bounds
      @bounding_box
    end

    # Sets Document#bounds to the BoundingBox provided.  See above for a brief
    # description of what a bounding box is.  This function is useful if you 
    # really need to change the bounding box manually, but usually, just entering
    # and exiting bounding box code blocks is good enough.
    #
    def bounds=(bounding_box)
      @bounding_box = bounding_box
    end

    # Moves up the document by n points relative to the current position inside
    # the current bounding box.
    # 
    def move_up(n)
      self.y += n
    end

    # Moves down the document by n points relative to the current position inside
    # the current bounding box.
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
    
    
    # Indents the specified number of PDF points for the duration of the block
    #
    #  pdf.text "some text"
    #  pdf.indent(20) do
    #    pdf.text "This is indented 20 points"
    #  end
    #  pdf.text "This starts 20 points left of the above line " +
    #           "and is flush with the first line"
    #
    def indent(x, &block)
      bounds.indent(x, &block)
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

    # Attempts to group the given block vertically within the current context.
    # First attempts to render it in the current position on the current page.
    # If that attempt overflows, it is tried anew after starting a new context
    # (page or column).
    #
    # Raises CannotGroup if the provided content is too large to fit alone in
    # the current page or column.
    #
    def group(second_attempt=false)
      old_bounding_box = @bounding_box
      @bounding_box = SimpleDelegator.new(@bounding_box)

      def @bounding_box.move_past_bottom
        raise RollbackTransaction
      end

      success = transaction { yield }

      unless success
        raise Prawn::Errors::CannotGroup if second_attempt
        old_bounding_box.move_past_bottom
        group(second_attempt=true) { yield }
      end 

      @bounding_box = old_bounding_box
    end

    # Specify a template for page numbering.  This should be called
    # towards the end of document creation, after all your content is already in
    # place.  In your template string, <page> refers to the current page, and
    # <total> refers to the total amount of pages in the doucment.
    #
    # Example:
    #
    #   Prawn::Document.generate("page_with_numbering.pdf") do
    #     text "Hai"
    #     start_new_page
    #     text "bai"
    #     start_new_page
    #     text "-- Hai again"
    #     number_pages "<page> in a total of <total>", [bounds.right - 50, 0]  
    #   end
    #
    def number_pages(string, position)
      page_count.times do |i|
        go_to_page(i+1)
        str = string.gsub("<page>","#{i+1}").gsub("<total>","#{page_count}")
        draw_text str, :at => position
      end
    end

    # Returns true if content streams will be compressed before rendering,
    # false otherwise
    #
    def compression_enabled?
      !!@compress
    end
    
    private

    def generate_margin_box
      old_margin_box = @margin_box
      @margin_box = BoundingBox.new(
        self,
        [ page.margins[:left], page.dimensions[-1] - page.margins[:top] ] ,
        :width => page.dimensions[-2] - (page.margins[:left] + page.margins[:right]),
        :height => page.dimensions[-1] - (page.margins[:top] + page.margins[:bottom])
      )

      # we must update bounding box if not flowing from the previous page
      #
      # FIXME: This may have a bug where the old margin is restored
      # when the bounding box exits.
      @bounding_box = @margin_box if old_margin_box == @bounding_box
    end
    
    def apply_margin_option(options)
      # Treat :margin as CSS shorthand with 1-4 values.
      margin = Array(options[:margin])
      positions = { 4 => [0,1,2,3], 3 => [0,1,2,1],
                    2 => [0,1,0,1], 1 => [0,0,0,0] }[margin.length]

      [:top, :right, :bottom, :left].zip(positions).each do |p,i|
        options[:"#{p}_margin"] ||= margin[i]
      end
    end
  end
end
