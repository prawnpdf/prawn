# encoding: utf-8

# document.rb : Implements PDF document generation for Prawn
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require "stringio"
require "prawn/document/page_geometry" 
require "prawn/document/bounding_box"
require "prawn/document/text"      
require "prawn/document/table"

module Prawn
  class Document  
    
    include Prawn::Graphics    
    include Prawn::Images
    include Text                             
    include PageGeometry                             
    
    attr_accessor :y, :margin_box
    attr_reader   :margins, :page_size, :page_layout

             
    # Creates and renders a PDF document. 
    #
    # The block argument is necessary only when you need to make 
    # use of a closure.     
    #      
    #  # Using implicit block form and rendering to a file
    #  Prawn::Document.generate "foo.pdf" do
    #     font "Times-Roman"   
    #     text "Hello World", :at => [200,720], :size => 32       
    #  end
    #         
    #  # Using explicit block form and rendering to a file   
    #  content = "Hello World"
    #  Prawn::Document.generate "foo.pdf" do |pdf|
    #     pdf.font "Times-Roman"
    #     pdf.text content, :at => [200,720], :size => 32
    #  end                                                
    #
    def self.generate(filename,options={},&block)
      pdf = Prawn::Document.new(options)          
      block.arity < 1 ? pdf.instance_eval(&block) : yield(pdf)
      pdf.render_file(filename)
    end
          
    # Creates a new PDF Document.  The following options are available:
    #
    # <tt>:page_size</tt>:: One of the Document::PageGeometry::SIZES [LETTER]
    # <tt>:page_layout</tt>:: Either <tt>:portrait</tt> or <tt>:landscape</tt>
    # <tt>:on_page_start</tt>:: Optional proc run at each page start
    # <tt>:on_page_stop</tt>:: Optional proc  run at each page stop   
    # <tt>:left_margin</tt>:: Sets the left margin in points [ 0.5 inch]
    # <tt>:right_margin</tt>:: Sets the right margin in points [ 0.5 inch]
    # <tt>:top_margin</tt>:: Sets the top margin in points [ 0.5 inch]
    # <tt>:bottom_margin</tt>:: Sets the bottom margin in points [0.5 inch]
    # <tt>:skip_page_creation</tt>:: Creates a document without starting the first page [false]
    # <tt>:compress</tt>:: Compresses content streams before rendering them [false]
    # 
    #                             
    #   # New document, US Letter paper, portrait orientation
    #   pdf = Prawn::Document.new                            
    #
    #   # New document, A4 paper, landscaped
    #   pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)    
    # 
    #   # New document, draws a line at the start of each new page
    #   pdf = Prawn::Document.new(:on_page_start => 
    #     lambda { |doc| doc.line [0,100], [300,100] } )
    #
    def initialize(options={})
       @objects = []
       @info    = ref(:Creator => "Prawn", :Producer => "Prawn")
       @pages   = ref(:Type => :Pages, :Count => 0, :Kids => [])  
       @root    = ref(:Type => :Catalog, :Pages => @pages)  
       @page_start_proc = options[:on_page_start]
       @page_stop_proc  = options[:on_page_stop]              
       @page_size   = options[:page_size]   || "LETTER"    
       @page_layout = options[:page_layout] || :portrait
       @compress = options[:compress] || false
             
       @margins = { :left   => options[:left_margin]   || 36,
                    :right  => options[:right_margin]  || 36,  
                    :top    => options[:top_margin]    || 36,       
                    :bottom => options[:bottom_margin] || 36  }
        
       generate_margin_box
       
       @bounding_box = @margin_box
       
       start_new_page unless options[:skip_page_creation]
     end     
            
     # Creates and advances to a new page in the document.
     # Runs the <tt>on_page_start</tt> lambda if one was provided at
     # document creation time (See Document.new).    
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
       generate_margin_box    
       @page_content = ref(:Length => 0)   
     
       @current_page = ref(:Type      => :Page, 
                           :Parent    => @pages, 
                           :MediaBox  => page_dimensions, 
                           :Contents  => @page_content)
       set_current_font    
       update_colors
       @pages.data[:Kids] << @current_page
       @pages.data[:Count] += 1 
     
       add_content "q"   
       
       @y = @margin_box.absolute_top        
       @page_start_proc[self] if @page_start_proc
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

    def compression_enabled?
      @compress
    end

   
    private 
    
    def generate_margin_box     
      old_margin_box = @margin_box
      @margin_box = BoundingBox.new(
        self,
        [ @margins[:left], page_dimensions[-1] - @margins[:top] ] ,
        :width => page_dimensions[-2] - (@margins[:left] + @margins[:right]),
        :height => page_dimensions[-1] - (@margins[:top] + @margins[:bottom])
      )                                 
            
      # update bounding box if not flowing from the previous page
      # TODO: This may have a bug where the old margin is restored
      # when the bounding box exits.
      @bounding_box = @margin_box if old_margin_box == @bounding_box              
    end
  
    def ref(data)
      @objects.push(Prawn::Reference.new(@objects.size + 1, data)).last
    end                                               
   
    def add_content(str)
     @page_content << str << "\n"
    end  

    # Add a new type to the current pages ProcSet
    def proc_set(*types)
      @current_page.data[:ProcSet] ||= ref([])
      @current_page.data[:ProcSet].data |= types
    end

    def page_resources
      @current_page.data[:Resources] ||= {}
    end

    def page_fonts
      page_resources[:Font] ||= {}
    end

    def page_xobjects
      page_resources[:XObject] ||= {}
    end
    
    def finish_page_content     
      @page_stop_proc[self] if @page_stop_proc
      add_content "Q"
      @page_content.compress_stream if compression_enabled?
      @page_content.data[:Length] = @page_content.stream.size
    end
    
    # Write out the PDF Header, as per spec 3.4.1
    def render_header(output)
      # pdf version
      output << "%PDF-1.3\n"

      # 4 binary chars, as recommended by the spec
      output << "\xFF\xFF\xFF\xFF\n"
    end

    # Write out the PDF Body, as per spec 3.4.2
    def render_body(output)
      @objects.each do |ref|
        ref.offset = output.size
        output << ref.object
      end
    end

    # Write out the PDF Cross Reference Table, as per spec 3.4.3
    def render_xref(output)
      @xref_offset = output.size
      output << "xref\n"
      output << "0 #{@objects.size + 1}\n"
      output << "0000000000 65535 f \n"
      @objects.each do |ref|
        output.printf("%010d", ref.offset)
        output << " 00000 n \n"
      end
    end

    # Write out the PDF Body, as per spec 3.4.4
    def render_trailer(output)
      trailer_hash = {:Size => @objects.size + 1, 
                      :Root => @root,
                      :Info => @info}

      output << "trailer\n"
      output << Prawn::PdfObject(trailer_hash) << "\n"
      output << "startxref\n" 
      output << @xref_offset << "\n"
      output << "%%EOF"
    end 
  end
end
