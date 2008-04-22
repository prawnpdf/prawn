require 'stringio'

module Prawn
  CRLF = "\r\n"

  class PDF

    def initialize
      # store all objects in this file
      @objects = []

      ##########
      # create the basic objects that will be in all PDFs
      ##########

      # root catalog
      @root = newobj

      # basic metadata 
      @info = newobj
      @info.data = {name("Creator") => "Prawn", name("Producer") => "Prawn"}

      # list of pages
      @pages = newobj
      @pages.data = {name("Type") => name("Pages"), name("Count") => 0, name("Kids") => []}

      # populate the root catalog
      @root.data = {name("Type") => name("Catalog"), name("Pages") => @pages}

      start_new_page
    end

    def stroke
      add_content("S")
    end

    def line(x0, y0, x1, y1)
      move_to(x0, y0).line_to(x1, y1)
      stroke
    end

    def line_to(x, y)
      add_content("%.3f %.3f l" % [ x, y ])
      self
    end

    def move_to(x, y)
      add_content("%.3f %.3f m" % [ x, y ])
      self
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
      #raise ArgumentError, "#{filename} already exists" if File.file?(filename)
      File.open(filename,"w") { |f| f.write render }
    end

    def start_new_page
      # finish off the previous page if necesary
      finish_page_content if @cur_content

      # create the new page
      @cur_page = newobj
      @cur_content = newobj
      @pages.data[name("Kids")] << @cur_page
      @pages.data[name("Count")] += 1
      @cur_page.data = {name("Type") => name("Page"), name("Parent") => @pages, name("MediaBox") => [0, 0, 595.28, 841.89], name("Contents") => @cur_content}
      @cur_content.stream = StringIO.new
      add_content("q")
      #add_content("10 M 100 741.89 m 200 641.89 l S")
      @cur_content.data = {name("Length") => 0}
    end

    private

    def add_content(str)
      @cur_content.stream << str << Prawn::CRLF
    end

    def finish_page_content
      add_content("Q")
      @cur_content.data[name("Length")] = @cur_content.stream.size
    end

    def name(str)
      if str.class == String
        Prawn::Name.new(str)
      else
        str
      end
    end

    def newobj
      obj = Prawn::Object.new(@objects.size + 1, 0)
      @objects << obj
      obj
    end

    # Write out the PDF Header, as per spec 3.4.1
    def render_header
      # pdf version
      @output << "%PDF-1.1" << Prawn::CRLF

      # 4 binary chars, as recommended by the spec
      @output << "\xFF\xFF\xFF\xFF" << Prawn::CRLF
    end

    # Write out the PDF Body, as per spec 3.4.2
    def render_body
      @objects.each do |obj|
        obj.offset = @output.size
        @output << obj.to_s
      end
    end

    # Write out the PDF Cross Reference Table, as per spec 3.4.3
    def render_xref
      @xref_offset = @output.size
      @output << "xref" << Prawn::CRLF
      @output << "0 #{@objects.size + 1}" << Prawn::CRLF
      @output << "0000000000 65535 f" << Prawn::CRLF
      @objects.each do |obj|
        @output.printf("%010d", obj.offset)
        @output << " 00000 n" << Prawn::CRLF
      end
    end

    # Write out the PDF Body, as per spec 3.4.4
    def render_trailer
      trailer_hash = {name("Size") => @objects.size + 1, name("Root") => @root, name("Info") => @info}

      @output << "trailer" << Prawn::CRLF
      @output << Prawn::Object.to_pdf(trailer_hash) << Prawn::CRLF
      @output << "startxref" << Prawn::CRLF
      @output << @xref_offset << Prawn::CRLF
      @output << "%%EOF"
    end
  end
end
