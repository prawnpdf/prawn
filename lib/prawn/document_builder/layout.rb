module Prawn
  class DocumentBuilder
    class Layout
      def initialize(builder, document)
        @builder  = builder
        @document = document
      end

      attr_reader :builder, :document

      def remaining_space
        Prawn::Document::BoundingBox.new(
          document.bounds, [0,document.cursor], 
          :width  => document.bounds.width, 
          :height => document.cursor
        )
      end

      def overflow(command)
        document.start_new_page
        builder.commands.unshift(command)
      end
    end
  end
end
