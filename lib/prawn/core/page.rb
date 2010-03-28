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
        mb = dictionary.data[:MediaBox]
        if mb[3] > mb[2]
          :portrait
        else
          :landscape
        end
      end

      def size
        dimensions[2,2]
      end

      def dimensions
        dictionary.data[:MediaBox]
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

      def dictionary
        @stamp_dictionary || document.state.store[@dictionary]
      end

      def resources
        if dictionary.data[:Resources]
          document.unref(dictionary.data[:Resources])
        else
          dictionary.data[:Resources] = {}
        end
      end

      def fonts
        if resources[:Font]
          document.unref(resources[:Font])
        else
          resources[:Font] = {}
        end
      end

      def xobjects
        if resources[:XObject]
          document.unref(resources[:XObject])
        else
          resources[:XObject] = {}
        end
      end

      def ext_gstates
        if resources[:ExtGState]
          document.unref(resources[:ExtGState])
        else
          resources[:ExtGState] = {}
        end
      end

      def finalize
        content.compress_stream if document.compression_enabled?
        content.data[:Length] = content.stream.size
      end

      private

      def init_from_object(options)
        @dictionary = options[:object_id].to_i
        @content    = dictionary.data[:Contents].identifier

        @stamp_stream      = nil
        @stamp_dictionary  = nil
      end

      def init_new_page(options)
        dimen = new_dimensions(options[:size], options[:layout])
        if dimen[3] > dimen[2]
          layout = :landscape
        else
          layout = :portrait
        end

        @content    = document.ref(:Length      => 0)
        @dictionary = document.ref(:Type        => :Page,
                                   :Parent      => document.state.store.pages,
                                   :MediaBox    => dimen,
                                   :Contents    => content)

        resources[:ProcSet] = [:PDF, :Text, :ImageB, :ImageC, :ImageI]

        @stamp_stream      = nil
        @stamp_dictionary  = nil
      end

      def new_dimensions(size, layout)
        size   ||=  "LETTER"
        layout ||= :portrait
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

    end
  end
end

