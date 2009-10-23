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
      # (or by passing Strings or Hashes as Table data).
      #
      # Cells can be used standalone, as a kind of limited-purpose bounding
      # box for laying out blocks of text, or they can be a single field
      # within a Table.
      #
      # The only initialization option that is always required is
      # <tt>:text</tt>.
      #
      # When using a Cell by itself, you must specify <tt>:point</tt>, and
      # <tt>:width</tt>.  Also, if creating the Cell directly rather than
      # using the Document#cell shortcut, you must provide <tt>:document</tt>
      # as well.
      #
      # When using a Cell as part of a table, many of the initialization
      # options are ignored (<tt>:width</tt>, <tt>:horizontal_padding</tt>,
      # <tt>:vertical_padding</tt>, <tt>:border_width</tt>,
      # <tt>:border_style</tt>, <tt>:align</tt>).
      #
      # <tt>:point</tt>::
      #   Absolute [x,y] coordinate of the top-left corner of the cell.
      # <tt>:document</tt>:: The Prawn::Document object to render on.
      # <tt>:text</tt>:: The text to be flowed within the cell
      # <tt>:text_color</tt>:: The color of the text to be displayed
      # <tt>:width</tt>:: The width in PDF points of the cell.
      # <tt>:height</tt>:: The height in PDF points of the cell.
      # <tt>:horizontal_padding</tt>:: The horizontal padding in PDF points
      # <tt>:vertical_padding</tt>:: The vertical padding in PDF points
      # <tt>:padding</tt>:: Overrides both horizontal and vertical padding
      # <tt>:align</tt>::
      #   One of <tt>:left</tt>, <tt>:right</tt>, <tt>:center</tt>
      # <tt>:borders</tt>::
      #   An array of sides which should have a border.  Any of <tt>:top</tt>,
      #   <tt>:left</tt>, <tt>:right</tt>, <tt>:bottom</tt>
      # <tt>:border_width</tt>:: The border line width. Defaults to 1.
      # <tt>:border_style</tt>::
      #   One of <tt>:all</tt>, <tt>:no_top</tt>, <tt>:no_bottom</tt>,
      #   <tt>:sides</tt>, <tt>:none</tt>, <tt>:bottom_only</tt>.  Defaults to
      #   :all.
      # <tt>:border_color</tt>:: The color of the cell border.
      # <tt>:font_size</tt>:: The font size for the cell text.
      # <tt>:font_style</tt>:: The font style for the cell text.
      # <tt>:colspan</tt>::
      #   The number of columns that the cell should occupy in the table.
      #
      def initialize(options={})
        @point              = options[:point]
        @document           = options[:document]
        @text               = options[:text].to_s
        @text_color         = options[:text_color]
        @width              = options[:width]
        @height             = options[:height]
        @borders            = options[:borders]
        @border_width       = options[:border_width] || 1
        @border_style       = options[:border_style] || :all
        @border_color       = options[:border_color]
        @background_color   = options[:background_color]
        @align              = options[:align] || :left
        @font_size          = options[:font_size]
        @font_style         = options[:font_style]
        @colspan            = options[:colspan]
        @horizontal_padding = options[:horizontal_padding] || 0
        @vertical_padding   = options[:vertical_padding]   || 0

        if options[:padding]
          @horizontal_padding = @vertical_padding = options[:padding]
        end
      end

      attr_accessor :point, :border_style, :border_width, :background_color,
                    :document, :horizontal_padding, :vertical_padding, :align,
                    :borders, :text_color, :border_color, :font_size,
                    :font_style, :colspan

      attr_writer   :height, :width #:nodoc:

      # Returns the cell's text as a string.
      #
      def to_s
        @text
      end

      # The width of the cell's text (in the appropriate font and
      # style), excluding the horizonal padding.
      #
      def natural_width
        with_cell_font do
          lengths = @text.lines.map { |e| @document.width_of(e) }
          return lengths.max.to_f
        end
      end

      # The width of the cell's text including horizontal padding.
      #
      def padded_natural_width
        natural_width + (2 * @horizontal_padding)
      end

      # The width of the cell's text excluding horizontal padding.
      def text_area_width
        width - (2 * @horizontal_padding)
      end

      # The width of the cell in PDF points
      #
      def width
        @width || padded_natural_width
      end

      # The height of the cell in PDF points
      #
      def height
        @height || text_area_height + 2*@vertical_padding
      end

      # The height of the text area excluding the vertical padding
      #
      def text_area_height
	with_cell_font do
          return @document.height_of(@text, text_area_width)
        end
      end

      # Draws the cell onto the PDF document
      #
      def draw
        margin = @border_width / 2.0

        if @background_color
          @document.mask(:fill_color) do
            @document.fill_color @background_color
            h  = borders.include?(:bottom) ?
              height - ( 2 * margin ) : height + margin
            @document.fill_rectangle [x,
                                      y ],
                width, h
          end
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
          @document.move_down((@document.font.line_gap - @document.font.descender)/2)

          options = {:align => @align, :final_gap => false}

          options[:size] = @font_size if @font_size
          options[:style] = @font_style if @font_style

          @document.mask(:fill_color) do
            @document.fill_color @text_color if @text_color
            @document.text @text, options
          end
        end
      end

      private

      # run a block with the document font set properly based on cell
      # attributes.
      #
      def with_cell_font
        @document.save_font do
          options = {}
          options[:style] = @font_style if @font_style
          font = @document.find_font(@document.font.name, options)
          @document.set_font(font)
          @document.font_size(@font_size) if @font_size
          yield
        end
      end

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
      end

      attr_reader :cells
      attr_accessor :background_color, :text_color, :border_color

      def <<(cell)
        @cells << cell
        self
      end

      # Once the widths of the cells in the CellBlock are set, the CellBlock
      # can figure out how high it should be.
      def height
        @cells.map { |c| c.height }.max
      end

      def column_count
        @cells.inject(0) { |acc, e| acc += e.colspan ? e.colspan : 1 }
      end

      def draw
        y = @document.y
        x = @document.bounds.absolute_left

        @cells.each do |e|
          e.point  = [x - @document.bounds.absolute_left,
                      y - @document.bounds.absolute_bottom]
          e.height = height
          e.background_color ||= @background_color
          e.text_color ||= @text_color
          e.border_color ||= @border_color
          e.draw
          x += e.width
        end

        @document.y = y - height
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
