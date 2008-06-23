module Prawn
  module Graphics
    class Cell
      def initialize(options={})
        @point    = options[:point]
        @document = options[:document]
        @text     = options[:text]
        @width    = options[:width]
        @border   = options[:border] 
        @padding  = options[:padding] || 0
        @style    = options[:style] || :all
      end

      attr_accessor :point, :style
      attr_writer   :height

      def text_area_width
        width - 2*@padding
      end

      def width
        @width || (@document.font_metrics.string_width(@text,
          @document.current_font_size)) + 2*@padding
      end

      def height
        @height || text_area_height + 2*@padding
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
            case(@style)
            when :all
              @document.stroke_rectangle rel_point, width, height
            when :sides
              @document.stroke_vertical_line_at(rel_point[0], rel_point[1],
                                                rel_point[1] - height)
              @document.stroke_vertical_line_at(rel_point[0] + width,
                                                rel_point[1],
                                                rel_point[1] - height)
            when :no_top
              @document.stroke_vertical_line_at(rel_point[0], rel_point[1],
                                                rel_point[1] - height)
              @document.stroke_vertical_line_at(rel_point[0] + width,
                                                rel_point[1],
                                                rel_point[1] - height)

              @document.stroke_line [rel_point[0], rel_point[1] - height],
                                    [rel_point[0]+width, rel_point[1] - height]
             when :no_bottom
              @document.stroke_vertical_line_at(rel_point[0], rel_point[1],
                                                rel_point[1] - height)
              @document.stroke_vertical_line_at(rel_point[0] + width,
                                                rel_point[1],
                                                rel_point[1] - height)

              @document.stroke_line rel_point,
                                    [rel_point[0]+width, rel_point[1]]
            end
          end
        end

        @document.bounding_box( [@point[0] + @padding, @point[1] - @padding], 
                                :width   => text_area_width,
                                :height  => height - @padding) do
          @document.text @text
        end
      end
    end

    # TODO: A temporary, entertaining name that should probably be changed.
    class CellBlock

      include Enumerable

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

      def each
        @cells.each { |e| yield(e) }
      end
    end
  end
 
  class Document
    def cell(point, options={})
      Prawn::Graphics::Cell.new(point,options.merge(:document => self)).draw
    end
  end
end
