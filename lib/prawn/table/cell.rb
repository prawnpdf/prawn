# encoding: utf-8   

# cell.rb: Table cell drawing.
#
# Copyright December 2009, Gregory Brown and Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document

    # Instantiates and draws a cell on the document. 
    #
    #   cell(:content => "Hello world!", :at => [12, 34])
    #
    # See Prawn::Table::Cell.make for full options.
    #
    def cell(options={})
      cell = Table::Cell.make(self, options.delete(:content), options)
      cell.draw
      cell
    end

  end

  class Table
    # TODO: doc
    class Cell

      attr_reader :padding
      attr_reader :min_width, :max_width
      attr_writer :height
      attr_accessor :borders, :border_width, :border_color, :content, 
        :background_color

      # Instantiates a Cell based on the given options. The particular class of
      # cell returned depends on the :content argument.
      #
      def self.make(pdf, content, options={})
        at = options.delete(:at) || [0, pdf.cursor]
        options[:content] = content

        case content
        when Prawn::Table::Cell
          content
        when String
          Cell::Text.new(pdf, at, options)
        when Prawn::Table
          Cell::Subtable.new(pdf, at, options)
        when Array
          subtable = Prawn::Table.new(options[:content], pdf, {})
          Cell::Subtable.new(pdf, at, options.merge(:content => subtable))
        else
          # TODO: other types of content
          raise ArgumentError, "Content type not recognized: #{content.inspect}"
        end
      end

      # A small amount added to the bounding box width to cover over floating-
      # point errors when round-tripping from content_width to width and back.
      #
      FPTolerance = 1

      # TODO: doc
      def initialize(pdf, point, options={})
        @pdf   = pdf
        @point = point

        # Set defaults; these can be changed by options
        @padding      = [5, 5, 5, 5]
        @borders      = [:top, :bottom, :left, :right]
        @border_width = 1
        @border_color = '000000'

        options.each { |k, v| send("#{k}=", v) }

        # Sensible defaults for min / max.
        @min_width = left_padding + right_padding
        @max_width = @pdf.bounds.width
      end

      # Returns the cell's width in points, inclusive of padding.
      #
      def width
        # We can't ||= here because the FP error accumulates on the round-trip
        # from #content_width.
        @width || (content_width + left_padding + right_padding)
      end

      # Manually sets the cell's width.
      #
      def width=(w)
        @width = @min_width = @max_width = w
      end

      # Returns the width of the bare content in the cell, excluding padding.
      #
      def content_width
        if @width # manually set
          return @width - left_padding - right_padding
        end

        natural_content_width
      end

      # Returns the width this cell would naturally take on, absent other
      # constraints. Must be implemented in subclasses.
      #
      def natural_content_width
        raise NotImplementedError, 
          "subclasses must implement natural_content_width"
      end

      # Returns the cell's height in points, inclusive of padding.
      #
      def height
        # We can't ||= here because the FP error accumulates on the round-trip
        # from #content_height.
        @height || (content_height + top_padding + bottom_padding)
      end

      # Returns the height of the bare content in the cell, excluding padding.
      #
      def content_height
        if @height # manually set
          return @height - top_padding - bottom_padding
        end
        
        natural_content_height
      end

      # Returns the height this cell would naturally take on, absent
      # constraints. Must be implemented in subclasses.
      #
      def natural_content_height
        raise NotImplementedError, 
          "subclasses must implement natural_content_height"
      end

      # Draws the cell onto the document. Pass in a point [x,y] to override the
      # location at which the cell is drawn.
      #
      def draw(pt=[x, y])
        draw_background(pt)
        draw_borders(pt)
        @pdf.bounding_box([pt[0] + left_padding, pt[1] - top_padding], 
                          :width  => content_width + FPTolerance,
                          :height => content_height + FPTolerance) do
          draw_content
        end
      end

      # x-position of the cell within the parent bounds.
      #
      def x
        @point[0]
      end

      # Set the x-position of the cell within the parent bounds.
      #
      def x=(val)
        @point[0] = val
      end

      # y-position of the cell within the parent bounds.
      #
      def y
        @point[1]
      end

      # Set the y-position of the cell within the parent bounds.
      #
      def y=(val)
        @point[1] = val
      end

      # Sets padding on this cell. The argument can be one of:
      #
      # * an integer (sets all padding)
      # * a two-element array [vertical_padding, horizontal_padding]
      # * a four-element array [top, right, bottom, left]
      #
      def padding=(pad)
        @padding = case
        when pad.nil?
          [0, 0, 0, 0]
        when Numeric === pad # all padding
          [pad, pad, pad, pad]
        when pad.length == 2 # vert, horiz
          [pad[0], pad[1], pad[0], pad[1]]
        when pad.length == 4 # top, right, bottom, left
          [pad[0], pad[1], pad[2], pad[3]]
        else
          raise ArgumentError, ":padding must be a number or an array [v,h] " +
            "or [t,r,b,l]"
        end
      end

      private

      # Draws the cell's background color.
      #
      def draw_background(pt)
        x, y = pt
        margin = @border_width / 2
        if @background_color
          @pdf.mask(:fill_color) do
            @pdf.fill_color @background_color
            h = @borders.include?(:bottom) ? height - (2*margin) : 
                                             height + margin
            @pdf.fill_rectangle [x, y], width, h
          end
        end
      end

      # Draws borders around the cell. Borders are centered on the bounds of
      # the cell outside of any padding, so the caller is responsible for
      # setting appropriate padding to ensure the border does not overlap with
      # cell content.
      #
      def draw_borders(pt)
        x, y = pt
        return if @border_width <= 0
        # Draw left / right borders one-half border width beyond the center of
        # the corner, so that the corners end up square.
        margin = @border_width / 2.0

        @pdf.mask(:line_width, :stroke_color) do
          @pdf.line_width   = @border_width
          @pdf.stroke_color = @border_color if @border_color

          @borders.each do |border|
            from, to = case border
                       when :top
                         [[x, y], [x+width, y]]
                       when :bottom
                         [[x, y-height], [x+width, y-height]]
                       when :left
                         [[x, y+margin], [x, y-height-margin]]
                       when :right
                         [[x+width, y+margin], [x+width, y-height-margin]]
                       end
            @pdf.stroke_line(from, to)
          end
        end
      end

      # Draws cell content within the cell's bounding box. Must be implemented
      # in subclasses.
      #
      def draw_content
        raise NotImplementedError, "subclasses must implement draw_content"
      end

      def top_padding
        @padding[0]
      end

      def right_padding
        @padding[1]
      end

      def bottom_padding
        @padding[2]
      end

      def left_padding
        @padding[3]
      end

    end
  end
end
