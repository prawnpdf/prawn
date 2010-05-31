# encoding: utf-8

# prawn/core/page.rb : Implements low-level representation of a PDF page
#
# Copyright February 2010, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
module Prawn
  module Core
    class Page #:nodoc:
      attr_accessor :document, :content, :dictionary, :margins

      def initialize(document, options={})
        @document = document
        @margins  = options[:margins] || { :left    => 36,
                                           :right   => 36,
                                           :top     => 36,
                                           :bottom  => 36  }

        if options[:object_id]
          init_from_object(options)
        else
          init_new_page(options)
        end
      end

      def layout
        return @layout if @layout

        mb = dictionary.data[:MediaBox]
        if mb[3] > mb[2]
          :portrait
        else
          :landscape
        end
      end

      def size
        @size || dimensions[2,2]
      end

      def in_stamp_stream?
        !!@stamp_stream
      end

      def stamp_stream(dictionary)
        @stamp_stream     = ""
        @stamp_dictionary = dictionary

        document.send(:update_colors)
        yield if block_given?
        document.send(:update_colors)

        @stamp_dictionary.data[:Length] = @stamp_stream.length + 1
        @stamp_dictionary << @stamp_stream

        @stamp_stream      = nil
        @stamp_dictionary  = nil
      end

      def content
        @stamp_stream || document.state.store[@content]
      end

      # As per the PDF spec, each page can have multiple content streams. This will
      # add a fresh, empty content stream this the page, mainly for use in loading
      # template files.
      #
      def new_content_stream
        return if in_stamp_stream?

        unless dictionary.data[:Contents].is_a?(Array)
          dictionary.data[:Contents] = [content]
        end
        @content    = document.ref(:Length => 0)
        dictionary.data[:Contents] << document.state.store[@content]
      end

      def dictionary
        @stamp_dictionary || document.state.store[@dictionary]
      end

      def resources
        if dictionary.data[:Resources]
          document.deref(dictionary.data[:Resources])
        else
          dictionary.data[:Resources] = {}
        end
      end

      def fonts
        if resources[:Font]
          document.deref(resources[:Font])
        else
          resources[:Font] = {}
        end
      end

      def xobjects
        if resources[:XObject]
          document.deref(resources[:XObject])
        else
          resources[:XObject] = {}
        end
      end

      def ext_gstates
        if resources[:ExtGState]
          document.deref(resources[:ExtGState])
        else
          resources[:ExtGState] = {}
        end
      end

      def finalize
        if dictionary.data[:Contents].is_a?(Array)
          dictionary.data[:Contents].each do |stream|
            stream.compress_stream if document.compression_enabled?
            stream.data[:Length] = stream.stream.size
          end
        else
          content.compress_stream if document.compression_enabled?
          content.data[:Length] = content.stream.size
        end
      end

      def imported_page?
        @imported_page
      end

      def dimensions
        return dictionary.data[:MediaBox] if imported_page?

        coords = Prawn::Document::PageGeometry::SIZES[size] || size
        [0,0] + case(layout)
        when :portrait
          coords
        when :landscape
          coords.reverse
        else
          raise Prawn::Errors::InvalidPageLayout,
            "Layout must be either :portrait or :landscape"
        end
      end

      private

      def init_from_object(options)
        @dictionary = options[:object_id].to_i
        unless dictionary.data[:Contents].is_a?(Array) # content only on leafs
          @content    = dictionary.data[:Contents].identifier
        end

        @stamp_stream      = nil
        @stamp_dictionary  = nil
        @imported_page     = true
      end

      def init_new_page(options)
        @size     = options[:size]    ||  "LETTER" 
        @layout   = options[:layout]  || :portrait         
        
        @content    = document.ref(:Length      => 0)
        @dictionary = document.ref(:Type        => :Page,
                                   :Parent      => document.state.store.pages,
                                   :MediaBox    => dimensions,
                                   :Contents    => content)

        resources[:ProcSet] = [:PDF, :Text, :ImageB, :ImageC, :ImageI]

        @stamp_stream      = nil
        @stamp_dictionary  = nil
      end

    end
  end
end

