require "stringio"

module Prawn
  class Document    
    
    def initialize
       @objects = []
       @info    = ref(:Creator => "Prawn", :Producer => "Prawn")
       @pages   = ref(:Type => :Pages, :Count => 0, :Kids => [])  
       @root    = ref(:Type => :Catalog, :Pages => @pages)  
       start_new_page
     end  
   
     def start_new_page
       finish_page_content if @page_content
       @page_content = ref(:Length => 0)   
     
       @current_page = ref(:Type     => :Page, 
                           :Parent   => @pages, 
                           :MediaBox => [0, 0, 595.28, 841.89], 
                           :Contents => @page_content) 
     
       @pages.data[:Kids] << @current_page
       @pages.data[:Count] += 1 
     
       add_content "q"   
    end   
    
    def stroke
      add_content "S"
    end

    def line(x0, y0, x1, y1)
      move_to(x0, y0)
      line_to(x1, y1)
    end

    def line_to(x, y)
      add_content("%.3f %.3f l" % [ x, y ]) 
      stroke
    end

    def move_to(x, y)
      add_content("%.3f %.3f m" % [ x, y ])
    end

    def render       
      finish_page_content

      @output = StringIO.new
      render_header
      render_body
      render_xref
      render_trailer
      @output.string
    end

    def render_file(filename)
      File.open(filename,"wb") { |f| f.write render }
    end

    private 
   
    def ref(data)
      @objects.push(Prawn::Reference.new(@objects.size + 1, data)).last
    end  
   
    def add_content(str)
     @page_content << str << "\n"
    end  
    
    def finish_page_content     
      add_content "Q"
      @page_content.data[:Length] = @page_content.stream.size
    end
    
    # Write out the PDF Header, as per spec 3.4.1
    def render_header
      # pdf version
      @output << "%PDF-1.1\n"

      # 4 binary chars, as recommended by the spec
      @output << "\xFF\xFF\xFF\xFF\n"
    end

    # Write out the PDF Body, as per spec 3.4.2
    def render_body
      @objects.each do |ref|
        ref.offset = @output.size
        @output << ref.object
      end
    end

    # Write out the PDF Cross Reference Table, as per spec 3.4.3
    def render_xref
      @xref_offset = @output.size
      @output << "xref\n"
      @output << "0 #{@objects.size + 1}\n"
      @output << "0000000000 65535 f \n"
      @objects.each do |ref|
        @output.printf("%010d", ref.offset)
        @output << " 00000 n \n"
      end
    end

    # Write out the PDF Body, as per spec 3.4.4
    def render_trailer
      trailer_hash = {:Size => @objects.size + 1, 
                      :Root => @root,
                      :Info => @info}

      @output << "trailer\n"
      @output << Prawn::PdfObject(trailer_hash) << "\n"
      @output << "startxref\n" 
      @output << @xref_offset << "\n"
      @output << "%%EOF"
    end 
  end
end