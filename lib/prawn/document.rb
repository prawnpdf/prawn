# document.rb : Implements PDF document generation for Prawn
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require "stringio"
require "prawn/document/graphics"
require "prawn/document/page_geometry"       

module Prawn
  class Document  
    
    include Graphics                                 
    include PageGeometry                             
    
    attr_accessor :page_size, :page_layout
    
    def initialize(options={})
       @objects = []
       @info    = ref(:Creator => "Prawn", :Producer => "Prawn")
       @pages   = ref(:Type => :Pages, :Count => 0, :Kids => [])  
       @root    = ref(:Type => :Catalog, :Pages => @pages)  
       @page_start_proc = options[:on_page_start]
       @page_stop_proc  = options[:on_page_end]              
       @page_size   = options[:page_size]   || "LETTER"    
       @page_layout = options[:page_layout] || :portrait
       
       start_new_page
     end  
                                                
     def start_new_page
       finish_page_content if @page_content
       @page_content = ref(:Length => 0)   
     
       @current_page = ref(:Type     => :Page, 
                           :Parent   => @pages, 
                           :MediaBox => page_dimensions, 
                           :Contents => @page_content) 
     
       @pages.data[:Kids] << @current_page
       @pages.data[:Count] += 1 
     
       add_content "q"   

       @page_start_proc[self] if @page_start_proc
    end             
    
    def page_count
      @pages.data[:Count]
    end

   def move_to(*point)
      x,y = point.flatten
      add_content("%.3f %.3f m" % [ x, y ])
    end

    def render(output=StringIO.new)       
      finish_page_content

      render_header(output)
      render_body(output)
      render_xref(output)
      render_trailer(output)
      output.string
    end

    def render_file(filename)
      File.open(filename,"wb") { |f| f.write render }
    end

    private
   
    def ref(data)
      @objects.push(Prawn::Reference.new(@objects.size + 1, data)).last
    end                                               
    
    def stroke
      add_content "S"
    end
   
    def add_content(str)
     @page_content << str << "\n"
    end  
    
    def finish_page_content     
      @page_stop_proc[self] if @page_stop_proc
      add_content "Q"
      @page_content.data[:Length] = @page_content.stream.size
    end
    
    # Write out the PDF Header, as per spec 3.4.1
    def render_header(output)
      # pdf version
      output << "%PDF-1.1\n"

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
