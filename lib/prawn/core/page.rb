module Prawn
  module Core
    class Page
      def initialize(document, options={})
        @document = document
        @size     = options[:size]   ||  "LETTER" 

        @layout   = options[:layout] || :portrait 

        @margins  = options[:margins] || { :left    => 36,
                                           :right   => 36,
                                           :top     => 36,
                                           :bottom  => 36 }

        @content    = document.ref(:Length      => 0)
        @dictionary = document.ref(:Type        => :Page,
                                   :Parent      => document.store.pages,
                                   :MediaBox    => dimensions,
                                   :Contents    => content)
      end

      attr_accessor :size, :layout, :margins, :document, :content, :dictionary

      def dimensions
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

      def content
        document.store[@content]
      end

      def dictionary
        document.store[@dictionary]
      end

      def resources
        dictionary.data[:Resources] ||= {}
      end

      def fonts
        resources[:Font] ||= {}
      end

      def xobjects
        resources[:XObject] ||= {}
      end

      def ext_gstates
        resources[:ExtGState] ||= {}
      end

    end
  end
end

