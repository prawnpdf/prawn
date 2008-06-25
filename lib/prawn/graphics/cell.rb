module Prawn
  module Graphics
    class Cell
      def initialize(options={})
        @point        = options[:point]
        @document     = options[:document]
        @text         = options[:text]
        @width        = options[:width]
        @border       = options[:border] || 1
        @border_style = options[:border_style] || :all

        @horizontal_padding = options[:horizontal_padding] || 0
        @vertical_padding   = options[:vertical_padding]   || 0

        if options[:padding]
          @horizontal_padding = @vertical_padding = options[:padding]
        end
      end

      attr_accessor :point, :border_style
      attr_writer   :height

      def text_area_width
        width - 2*@horizontal_padding
      end

      def width
        @width || (@document.font_metrics.string_width(@text,
          @document.current_font_size)) + 2*@horizontal_padding
      end

      def height
        @height || text_area_height + 2*@vertical_padding
      end

      def text_area_height
        @document.font_metrics.string_height(@text, 
         :font_size  => @document.current_font_size, 
         :line_width => text_area_width) 
      end

      def draw
        rel_point = [@point[0] - @document.bounds.absolute_left,
                     @point[1] - @document.bounds.absolute_bottom]
        if @border
          @document.mask(:line_width) do
            @document.line_width = @border

            if borders.include?(:left)
              @document.stroke_line rel_point, [rel_point[0], rel_point[1] - height]
            end

            if borders.include?(:right)
              @document.stroke_line rel_point[0] + width, rel_point[1],
                                  rel_point[0] + width, rel_point[1] - height
            end

            if borders.include?(:top)
              @document.stroke_line rel_point, [ rel_point[0] + width, rel_point[1] ]
            end

            if borders.include?(:bottom)
              @document.stroke_line [rel_point[0], rel_point[1] - height],
                                  [rel_point[0] + width, rel_point[1] - height]
            end

          end
          
          borders

        end

        @document.bounding_box( [@point[0] + @horizontal_padding, 
                                 @point[1] - @vertical_padding], 
                                :width   => text_area_width,
                                :height  => height - @vertical_padding) do
          @document.text @text
        end
      end

      def borders
        @borders ||= case @border_style
        when :all
          [:top,:left,:right,:bottom]
        when :sides
          [:left,:right]
        when :no_top
          [:left,:right,:bottom]
        when :no_bottom
          [:left,:right,:top]
        end
      end

    end

    # TODO: A temporary, entertaining name that should probably be changed.
    class CellBlock
      def initialize(document)
        @document = document
        @cells    = []
        @width    = 0
        @height   = 0
      end

      attr_reader :width, :height

      def <<(cell)
        @cells << cell
        @height = cell.height if cell.height > @height
        @width += cell.width
        self
      end

      def draw
        y = @document.y
        x = @document.bounds.absolute_left

        @cells.each do |e|
          e.point  = [x,y]
          e.height = @height
          e.draw
          x += e.width
        end
        
        @document.y = y - @height
      end

      def border_style=(s)
        @cells.each { |e| e.border_style = s }
      end

    end
  end
 
  class Document
    def cell(point, options={})
      Prawn::Graphics::Cell.new(options.merge(:document => self, :point => point)).draw
    end
  end
end
