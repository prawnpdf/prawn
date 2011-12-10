# encoding: utf-8   

# span_dummy.rb: Placeholder for non-master spanned cells.
#
# Copyright December 2011, Brad Ediger. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
module Prawn
  class Table
    class Cell

      # A Cell object used to represent all but the topmost cell in a span
      # group.
      #
      class SpanDummy < Cell
        def initialize(pdf, master_cell)
          super(pdf, [0, pdf.cursor])
          @master_cell = master_cell
          @padding = [0, 0, 0, 0]
        end

        # By default, a span dummy will never increase the height demand.
        #
        def natural_content_height
          0
        end

        # By default, a span dummy will never increase the width demand.
        #
        def natural_content_width
          0
        end

        # Dummy cells have nothing to draw.
        #
        def draw_borders(pt)
        end

        # Dummy cells have nothing to draw.
        #
        def draw_bounded_content(pt)
        end
      end
    end
  end
end
