module Prawn

  class Document
    # Builds and renders a Graphics::Cell.  A cell is essentially a
    # special-purpose bounding box designed for flowing text within a bordered
    # area.  For available options, see Graphics::Cell#new.
    #
    #    Prawn::Document.generate("cell.pdf") do
    #       cell [100,500], 
    #         :width => 200,
    #         :text  => "The rain in Spain falls mainly on the plains"
    #    end
    #
    def cell(point, options={})
      Prawn::Graphics::Cell.new(options.merge(:document => self, :point => point)).draw
    end
  end

  module Graphics
    # A cell is a special-purpose bounding box designed to flow text within a
    # bordered area. This is used by Prawn's Document::Table implementation but
    # can also be used standalone for drawing text boxes via Document#cell
    #
    class Cell

      # Creates a new cell object.  Generally used indirectly via Document#cell
      #
      # Of the available options listed below, <tt>:point</tt>, <tt>:width</tt>,
      # and <tt>:text</tt> must be provided. If you are not using the
      # Document#cell shortcut, the <tt>:document</tt> must also be provided.
      #
      # <tt>:point</tt>:: Absolute [x,y] coordinate of the top-left corner of the cell.
      # <tt>:document</tt>:: The Prawn::Document object to render on. 
      # <tt>:text</tt>:: The text to be flowed within the cell
      # <tt>:width</tt>:: The width in PDF points of the cell.
      # <tt>:border</tt>:: The border line width. If omitted, no border will be drawn.
      # <tt>:horizontal_padding</tt>:: The horizontal padding in PDF points
      # <tt>:vertical_padding</tt>:: The vertical padding in PDF points
      # <tt>:padding</tt>:: Overrides both horizontal and vertical padding
      # <tt>:border_style</tt>:: One of <tt>:all</tt>, <tt>:no_top<tt>, <tt>:no_bottom</tt>, <tt>:sides</tt>
      #
      def initialize(options={})
        @point        = options[:point]
        @document     = options[:document]
        @text         = options[:text]
        @width        = options[:width]
        @border       = options[:border]
        @border_style = options[:border_style] || :all

        @horizontal_padding = options[:horizontal_padding] || 0
        @vertical_padding   = options[:vertical_padding]   || 0

        if options[:padding]
          @horizontal_padding = @vertical_padding = options[:padding]
        end
      end

      attr_accessor :point, :border_style, :border
      attr_writer   :height #:nodoc:

      # The width of the text area excluding the horizonal padding
      #
      def text_area_width
        width - 2*@horizontal_padding
      end

      # The width of the cell in PDF points
      #
      def width
        @width || (@document.font_metrics.string_width(@text,
          @document.current_font_size)) + 2*@horizontal_padding
      end

      # The height of the cell in PDF points
      #
      def height
        @height || text_area_height + 2*@vertical_padding
      end

      # The height of the text area excluding the vertical padding
      #
      def text_area_height
        @document.font_metrics.string_height(@text, 
         :font_size  => @document.current_font_size, 
         :line_width => text_area_width) 
      end

      # Draws the cell onto the PDF document
      # 
      def draw
        rel_point = [@point[0] - @document.bounds.absolute_left,
                     @point[1] - @document.bounds.absolute_bottom]
        if @border
          @document.mask(:line_width) do
            @document.line_width = @border

            if borders.include?(:left)
              @document.stroke_line [rel_point[0], rel_point[1] + (@border / 2.0)], 
                [rel_point[0], rel_point[1] - height - @border / 2.0 ]
            end

            if borders.include?(:right)
              @document.stroke_line( 
                [rel_point[0] + width, rel_point[1] + (@border / 2.0)],
                [rel_point[0] + width, rel_point[1] - height - @border / 2.0] )
            end

            if borders.include?(:top)
              @document.stroke_line(
                [ rel_point[0] + @border / 2.0, rel_point[1] ], 
                [ rel_point[0] - @border / 2.0 + width, rel_point[1] ])
            end

            if borders.include?(:bottom)
              @document.stroke_line [rel_point[0], rel_point[1] - height ],
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

      private

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

    class CellBlock #:nodoc:

      # Not sure if this class is something I want to expose in the public API.

      def initialize(document)
        @document = document
        @cells    = []
        @width    = 0
        @height   = 0
      end

      attr_reader :width, :height
      attr_accessor :background_color

      def <<(cell)
        @cells << cell
        @height = cell.height if cell.height > @height
        @width += cell.width
        self
      end

      def draw
        y = @document.y
        x = @document.bounds.absolute_left

        # TODO: This is a bit of a hack and can be cleaned up
        if @background_color
          old_fill_color, old_stroke_color = 
           @document.instance_eval { [@fill_color, @stroke_color] }
          @document.fill_color @background_color
          @document.stroke_color @background_color

          @document.canvas do
            @document.fill_rectangle [x+border,y-border], 
              width-2*border, height-2*border
          end

          @document.fill_color old_fill_color || "000000"
          @document.stroke_color old_stroke_color || "000000"
        end

        @cells.each do |e|
          e.point  = [x,y]
          e.height = @height
          e.draw
          x += e.width
        end
        
        @document.y = y - @height
      end

      def border
        @cells[0].border
      end

      def border_style=(s)
        @cells.each { |e| e.border_style = s }
      end

    end
  end
 
end
