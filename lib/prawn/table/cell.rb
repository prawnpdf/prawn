# encoding: utf-8   

# cell.rb : Table support functions
#
# Copyright June 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn

  class Document
    # Builds and renders a Table::Cell.  A cell is essentially a
    # special-purpose bounding box designed for flowing text within a bordered
    # area.  For available options, see Table::Cell#new.
    #
    #    Prawn::Document.generate("cell.pdf") do
    #       cell [100,500], 
    #         :width => 200,
    #         :text  => "The rain in Spain falls mainly on the plains"
    #    end
    #
    def cell(point, options={})
      Prawn::Table::Cell.new(
        options.merge(:document => self, :point => point)).draw
    end
  end

  class Table
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
      # <tt>:text_color</tt>:: The color of the text to be displayed
      # <tt>:width</tt>:: The width in PDF points of the cell.
      # <tt>:height</tt>:: The height in PDF points of the cell.
      # <tt>:horizontal_padding</tt>:: The horizontal padding in PDF points
      # <tt>:vertical_padding</tt>:: The vertical padding in PDF points
      # <tt>:padding</tt>:: Overrides both horizontal and vertical padding
      # <tt>:align</tt>:: One of <tt>:left</tt>, <tt>:right</tt>, <tt>:center</tt>
      # <tt>:borders</tt>:: An array of sides which should have a border. Any of <tt>:top</tt>, <tt>:left</tt>, <tt>:right</tt>, <tt>:bottom</tt>
      # <tt>:border_width</tt>:: The border line width. Defaults to 1.
      # <tt>:border_style</tt>:: One of <tt>:all</tt>, <tt>:no_top</tt>, <tt>:no_bottom</tt>, <tt>:sides</tt>, <tt>:none</tt>, <tt>:bottom_only</tt>. Defaults to :all.
      # <tt>:border_color</tt>:: The color of the cell border.
      # <tt>:font_size</tt>:: The font size for the cell text.
      # <tt>:font_style</tt>:: The font style for the cell text.
      #
      def initialize(options={})
        @point        = options[:point]
        @document     = options[:document]
        @text         = options[:text].to_s
        @text_color   = options[:text_color]
        @width        = options[:width]
        @height       = options[:height]
        @borders      = options[:borders]
        @border_width = options[:border_width] || 1
        @border_style = options[:border_style] || :all               
        @border_color = options[:border_color]
        @background_color = options[:background_color] 
        @align            = options[:align] || :left
        @font_size        = options[:font_size]
        @font_style       = options[:font_style]

        @horizontal_padding = options[:horizontal_padding] || 0
        @vertical_padding   = options[:vertical_padding]   || 0

        if options[:padding]
          @horizontal_padding = @vertical_padding = options[:padding]
        end
        
      end

      attr_accessor :point, :border_style, :border_width, :background_color,
                    :document, :horizontal_padding, :vertical_padding, :align,
                    :borders, :text_color, :border_color, :font_size, :font_style
                    
      attr_writer   :height, :width #:nodoc:   
           
      # Returns the cell's text as a string.
      #
      def to_s
        @text
      end

      # The width of the text area excluding the horizonal padding
      #
      def text_area_width
        width - 2*@horizontal_padding
      end

      # The width of the cell in PDF points
      #
      def width
        @width || (@document.width_of(@text, :size => @font_size)) + 2*@horizontal_padding
      end

      # The height of the cell in PDF points
      #
      def height  
        @height || text_area_height + 2*@vertical_padding
      end

      # The height of the text area excluding the vertical padding
      #
      def text_area_height
        text_height = 0
        if @font_size
          @document.font_size(@font_size) do
            text_height = @document.height_of(@text, :width => text_area_width)
          end
        else
          text_height = @document.height_of(@text, :width => text_area_width)
        end
        text_height
      end

      # Draws the cell onto the PDF document
      # 
      def draw
        margin = @border_width / 2.0
        
        if @background_color    
          old_color = @document.fill_color || "000000"
          @document.fill_color(@background_color)
          h  = borders.include?(:bottom) ? 
          height - ( 2 * margin ) : height + margin
          @document.fill_rectangle [x, y ], width, h  

          @document.fill_color(old_color)
        end

        if @border_width > 0
          @document.mask(:line_width) do
            @document.line_width = @border_width

            @document.mask(:stroke_color) do
              @document.stroke_color @border_color if @border_color

              if borders.include?(:left)
                @document.stroke_line [x, y + margin], 
                  [x, y - height - margin ]
              end

              if borders.include?(:right)
                @document.stroke_line( 
                  [x + width, y + margin],
                  [x + width, y - height - margin] )
              end

              if borders.include?(:top)
                @document.stroke_line(
                  [ x, y ], 
                  [ x + width, y ])
              end

              if borders.include?(:bottom)
                @document.stroke_line [x, y - height ],
                                    [x + width, y - height]
              end
            end

          end
          
          borders

        end

        @document.bounding_box( [x + @horizontal_padding, 
                                 y - @vertical_padding], 
                                :width   => text_area_width,
                                :height  => height - @vertical_padding) do
          @document.move_down((@document.font.line_gap +
                               @document.font.descender) / 2)

          options = {:align => @align, :final_gap => false}

          options[:size] = @font_size if @font_size
          options[:style] = @font_style if @font_style

          old_color = @document.fill_color || "000000"
          @document.fill_color @text_color if @text_color                        
          @document.text @text, options
          @document.fill_color old_color
        end
      end

      private
      
      # x-position of the cell
      def x
        @point[0]
      end
      
      # y-position of the cell
      def y
        @point[1]
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
        when :bottom_only
          [:bottom]
        when :none
          []
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

      attr_reader :width, :height, :cells
      attr_accessor :background_color, :text_color, :border_color

      def <<(cell)
        @cells << cell
        @height = cell.height if cell.height > @height 
        @width += cell.width
        self
      end

      def draw
        y = @document.y
        x = @document.bounds.left_side

        @cells.each do |e|
          e.point  = [x - @document.bounds.absolute_left, 
                      y - @document.bounds.absolute_bottom]
          e.height = @height
          e.background_color ||= @background_color
          e.text_color ||= @text_color
          e.border_color ||= @border_color
          e.draw
          x += e.width
        end
        
        @document.y = y - @height
      end

      def border_width
        @cells[0].border_width
      end

      def border_style=(s)
        @cells.each { |e| e.border_style = s }
      end    
      
      def align=(align) 
        @cells.each { |e| e.align = align } 
      end           
      
      def border_style
        @cells[0].border_style
      end

    end
  end
 
end
