# encoding: utf-8   

# cell.rb: Table cell drawing.
#
# Copyright December 2009, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  class Document
    def cell(options={})
      at = options[:at] || [0, cursor]
      cell = Table::Cell.new(self, at, options)
      cell.draw
      cell
    end
  end

  class Table
    class Cell

      attr_reader :padding

      def initialize(pdf, point, options={})
        @pdf       = pdf
        @point     = point
        @width     = options[:width]
        @padding   = interpret_padding(options[:padding])
        @content   = options[:content]
      end

      # Returns the cell's width in points, inclusive of padding.
      #
      def width
        @width ||= (content_width + @padding[1] + @padding[3])
      end
      
      def content_width
        if @width # manually set
          return @width - @padding[1] - @padding[3]
        end

        @pdf.width_of(@content)
      end

      def draw
        # TODO
      end

      private

      def interpret_padding(pad)
        case
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


    end
  end
end
