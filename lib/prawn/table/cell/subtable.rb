# encoding: utf-8   

# subtable.rb: Yo dawg.
#
# Copyright January 2010, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  class Table
    class Cell

      # A Cell that contains another table.
      #
      class Subtable < Cell

        attr_reader :subtable

        def initialize(pdf, point, options={})
          super
          @subtable = options[:content]

          # Subtable padding defaults to zero
          @padding = [0, 0, 0, 0]
        end

        def natural_content_width
          @subtable.cells.width
        end

        def min_width
          @subtable.cells.min_width
        end

        def max_width
          @subtable.cells.max_width
        end

        def natural_content_height
          @subtable.cells.height
        end

        def draw_content
          @subtable.draw
        end

      end
    end
  end
end
