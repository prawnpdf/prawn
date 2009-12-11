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

      def initialize(pdf, point, options={})
        @pdf     = pdf
        @point   = point
        @content = options[:content]
        @width   = options[:width]
      end

      def width
        @width ||= @pdf.width_of(@content)
      end

      def draw
        # TODO
      end


    end
  end
end
