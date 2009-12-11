# encoding: utf-8   

# cell.rb: Table cell drawing.
#
# Copyright December 2009, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
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


    end
  end
end
