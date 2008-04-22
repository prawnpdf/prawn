require 'stringio'

module Prawn
  CRLF = "\n"

  class PDF

    def initialize
      # store all objects in this file
      @objects = []

      # create the basic objects that will be in all PDFs
      # root catalog
      @root = newobj

      # list of pages
      @pages = newobj 
      @pages.data = {}

      # populate the root catalog
      @root.data = {"Pages" => @pages.to_ref}
    end

    def render
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

    private

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
      trailer_hash = {"Size" => @objects.size, "Root" => @root.to_ref}

      @output << "trailer" << Prawn::CRLF
      @output << Prawn::Object.to_pdf(trailer_hash) << Prawn::CRLF
      @output << "startxref" << Prawn::CRLF
      @output << @xref_offset << Prawn::CRLF
      @output << "%%EOF"
    end
  end
end
