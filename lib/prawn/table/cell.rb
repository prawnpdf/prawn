# encoding: utf-8   

# cell.rb: Table cell drawing.
#
# Copyright December 2009, Gregory Brown and Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  class Document
    def cell(options={})
      at = options.delete(:at) || [0, cursor]
      # TODO: create appropriate class depending on content
      cell = Table::Cell::Text.new(self, at, options)
      cell.draw
      cell
    end
  end

  class Table
    class Cell

      attr_reader :padding, :font
      attr_writer :width, :height
      attr_accessor :borders, :border_width, :border_color, :content, 
        :background_color

      def initialize(pdf, point, options={})
        @pdf   = pdf
        @point = point

        # Set defaults; these can be changed by options
        @padding      = [0, 0, 0, 0]
        @borders      = [:top, :bottom, :left, :right]
        @border_width = 1
        @border_color = '000000'

        options.each { |k, v| send("#{k}=", v) }
      end

      # Returns the cell's width in points, inclusive of padding.
      #
      def width
        # We can't ||= here because the FP error accumulates on the round-trip
        # from #content_width.
        @width || (content_width + left_padding + right_padding)
      end

      # Returns the width of the bare content in the cell, excluding padding.
      #
      def content_width
        if @width # manually set
          return @width - left_padding - right_padding
        end

        natural_content_width
      end

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

      def natural_content_height
        raise NotImplementedError, 
          "subclasses must implement natural_content_height"
      end

      # Draws the cell onto the document.
      #
      def draw
        draw_background
        draw_borders
        @pdf.bounding_box([x + left_padding, y - top_padding], 
                          :width  => content_width,
                          :height => content_height) do
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
      def draw_background
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

      def draw_borders
        return if @border_width <= 0
        margin = @border_width / 2

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
                         [[x+width, y+margin], [x+width, y-height+margin]]
                       end
            @pdf.stroke_line(from, to)
          end
        end
      end

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
