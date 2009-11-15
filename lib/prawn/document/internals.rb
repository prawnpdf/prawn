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
      # Returns the identifier which points to the reference in the ObjectStore   
      # 
      def ref(data)
        ref!(data).identifier
      end                                               

      # Like ref, but returns the actual reference instead of its identifier.
      # 
      # While you can use this to build up nested references within the object
      # tree, it is recommended to persist only identifiers, and them provide
      # helper methods to look up the actual references in the ObjectStore
      # if needed.  If you take this approach, Prawn::Document::Snapshot
      # will probably work with your extension
      #
      def ref!(data)
        @store.ref(data)
      end

      # Grabs the reference for the current page content
      #
      def page_content
        @active_stamp_stream || @store[@page_content]
      end

      # Grabs the reference for the current page
      #
      def current_page
        @active_stamp_dictionary || @store[@current_page]
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
        page_content << str << "\n"
      end  

      # The Resources dictionary for the current page
      #
      def page_resources
        current_page.data[:Resources] ||= {}
      end
      
      # The Font dictionary for the current page
      #
      def page_fonts
        page_resources[:Font] ||= {}
      end
       
      # The XObject dictionary for the current page
      #
      def page_xobjects
        page_resources[:XObject] ||= {}
      end

      def page_ext_gstates
        page_resources[:ExtGState] ||= {}
      end
      
      # The Name dictionary (PDF spec 3.6.3) for this document. It is
      # lazily initialized, so that documents that do not need a name
      # dictionary do not incur the additional overhead.
      #
      def names
        @store.root.data[:Names] ||= ref!(:Type => :Names)
      end

      # Defines a block to be called just before the document is rendered.
      #
      def before_render(&block)
        @before_render_callbacks << block
      end

      def go_to_page(k) # :nodoc:
        jump_to = @store.pages.data[:Kids][k]
        @current_page = jump_to.identifier
        @page_content = jump_to.data[:Contents].identifier
      end

      private      

      def finalize_all_page_contents
        page_count.times do |i|
          go_to_page i
          @header.draw if defined?(@header) and @header
          @footer.draw if defined?(@footer) and @footer
          add_content "Q"
          page_content.compress_stream if compression_enabled?
          page_content.data[:Length] = page_content.stream.size
        end
      end

      # raise the PDF version of the file we're going to generate.
      # A private method, designed for internal use when the user adds a feature
      # to their document that requires a particular version.
      def min_version(min)
        @version = min if min > @version
      end

      # Write out the PDF Header, as per spec 3.4.1
      #
      def render_header(output)
        @before_render_callbacks.each{ |c| c.call(self) }

        # pdf version
        output << "%PDF-#{@version}\n"

        # 4 binary chars, as recommended by the spec
        output << "%\xFF\xFF\xFF\xFF\n"
      end

      # Write out the PDF Body, as per spec 3.4.2
      #
      def render_body(output)
        @store.each do |ref|
          ref.offset = output.size
          output << ref.object
        end
      end

      # Write out the PDF Cross Reference Table, as per spec 3.4.3
      #
      def render_xref(output)
        @xref_offset = output.size
        output << "xref\n"
        output << "0 #{@store.size + 1}\n"
        output << "0000000000 65535 f \n"
        @store.each do |ref|
          output.printf("%010d", ref.offset)
          output << " 00000 n \n"
        end
      end

      # Write out the PDF Trailer, as per spec 3.4.4
      #
      def render_trailer(output)
        trailer_hash = {:Size => @store.size + 1, 
                        :Root => @store.root,
                        :Info => @store.info}
        trailer_hash.merge!(@trailer) if @trailer

        output << "trailer\n"
        output << Prawn::PdfObject(trailer_hash) << "\n"
        output << "startxref\n" 
        output << @xref_offset << "\n"
        output << "%%EOF" << "\n"
      end
                 
    end
  end
end
