# encoding: utf-8
#
# internals.rb : Implements document internals for Prawn
#
# Copyright August 2008, Gregory Brown. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document     
    
    # This module exposes a few low-level PDF features for those who want
    # to extend Prawn's core functionality.  If you are not comfortable with
    # low level PDF functionality as defined by Adobe's specification, chances
    # are you won't need anything you find here.  
    #
    module Internals    
      # Creates a new Prawn::Reference and adds it to the Document's object
      # list.  The +data+ argument is anything that Prawn::PdfObject() can convert.    
      # 
      # If a block is given, it will be invoked just before the object is written
      # out to the PDF document stream. This allows you to do deferred processing
      # on some references (such as fonts, which you might know all the details
      # about until the last page of the document is finished).
      def ref(data, &block)
        @objects.push(Prawn::Reference.new(@objects.size + 1, data, &block)).last
      end                                               
      
      # Appends a raw string to the current page content.
      #                               
      #  # Raw line drawing example:           
      #  x1,y1,x2,y2 = 100,500,300,550
      #  pdf.add_content("%.3f %.3f m" % [ x1, y1 ])  # move 
      #  pdf.add_content("%.3f %.3f l" % [ x2, y2 ])  # draw path
      #  pdf.add_content("S") # stroke                    
      #
      def add_content(str)
       @page_content << str << "\n"
      end  

      # Add a new type to the current pages ProcSet 
      #
      def proc_set(*types)
        @current_page.data[:ProcSet] ||= ref([])
        @current_page.data[:ProcSet].data |= types
      end
             
      # The Resources dictionary for the current page
      #
      def page_resources
        @current_page.data[:Resources] ||= {}
      end
      
      # The Font dictionary for the current page
      #
      def page_fonts
        page_resources[:Font] ||= {}
      end
       
      # The XObject dictionary for the current page
      def page_xobjects
        page_resources[:XObject] ||= {}
      end  
      
      # The Name dictionary (PDF spec 3.6.3) for this document. It is
      # lazily initialized, so that documents that do not need a name
      # dictionary do not incur the additional overhead.
      def names
        @root.data[:Names] ||= ref(:Type => :Names)
      end

      private      
      
      def finish_page_content     
        @header.draw if @header      
        @footer.draw if @footer
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

      # Write out the PDF Trailer, as per spec 3.4.4
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
end
