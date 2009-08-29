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
require "prawn/document/text"      
require "prawn/document/internals"
require "prawn/document/span"
require "prawn/document/annotations"
require "prawn/document/destinations"

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
    #   Prawn::Document.generate "example.pdf" do
    #     # self here is set to the newly instantiated Prawn::Document
    #     # and so any variables in the outside scope are unavailable
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
    #   Prawn::Document.generate "example.pdf" do |pdf|
    #     # self here is left alone
    #     pdf.font "Times-Roman"
    #     pdf.text content, :at => [200,720], :size => 32
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
    # <tt>:left_margin</tt>:: Sets the left margin in points [0.5 inch]
    # <tt>:right_margin</tt>:: Sets the right margin in points [0.5 inch]
    # <tt>:top_margin</tt>:: Sets the top margin in points [0.5 inch]
    # <tt>:bottom_margin</tt>:: Sets the bottom margin in points [0.5 inch]
    # <tt>:skip_page_creation</tt>:: Creates a document without starting the first page [false]
    # <tt>:compress</tt>:: Compresses content streams before rendering them [false]
    # <tt>:background</tt>:: An image path to be used as background on all pages [nil]
    # <tt>:info</tt>:: Generic hash allowing for custom metadata properties [nil]

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
       Prawn.verify_options [:page_size, :page_layout, :left_margin, 
         :right_margin, :top_margin, :bottom_margin, :skip_page_creation, 
         :compress, :skip_encoding, :text_options, :background, :info], options
      
       options[:info] ||= {}
       options[:info][:Creator] ||= "Prawn"
       options[:info][:Producer] = "Prawn"

       options[:info].keys.each do |key|
         if options[:info][key].kind_of?(String)
           options[:info][key] = Prawn::LiteralString.new(options[:info][key])
         end
       end
          
       @version = 1.3
       @objects = ObjectStore.new
       @info    = ref(options[:info])
       @pages   = ref(:Type => :Pages, :Count => 0, :Kids => [])
       @root    = ref(:Type => :Catalog, :Pages => @pages)
       @page_size       = options[:page_size]   || "LETTER"
       @page_layout     = options[:page_layout] || :portrait
       @compress        = options[:compress] || false
       @skip_encoding   = options[:skip_encoding]
       @background      = options[:background]
       @font_size       = 12

       @text_options = options[:text_options] || {}

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
     #   pdf.start_new_page #=> Starts new page keeping current values
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

    # Renders the PDF document to string, useful for example in a Rails 
    # application where you want to stream out the PDF to a web browser:
    # 
    #  def show
    #    pdf = Prawn::Document.new do
    #      text "Putting PDF generation code in a controller is _BAD_"
    #    end
    #    send(pdf.render, :filename => 'silly.pdf', :type => 'application/pdf', :disposition => 'inline)
    #  end
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
    # and existing bounding box code blocks is good enough.
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
