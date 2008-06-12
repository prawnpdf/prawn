module Prawn
  module Graphics
    class Cell
      def initialize(point, options={})
        @point    = point
        @document = options[:document]
        @text     = options[:text]
        @width    = options[:width]
        @border   = options[:border] 
        @padding  = options[:padding] || 0
      end

      def draw
        box_height = 0
        @document.bounding_box( [@point[0] + @padding, @point[1] - @padding], 
                                :width => @width - 2*@padding) do
          @document.text @text
          box_height = @document.bounds.height
        end

        if @border
          @document.mask(:line_width) do
            @document.line_width = @border
            @document.stroke_rectangle @point, @width,  box_height+ 2*@padding
          end
        end
      end
    end
  end
 
  class Document
    def cell(point, options={})
      Prawn::Graphics::Cell.new(point,options.merge(:document => self)).draw
    end
  end
end
