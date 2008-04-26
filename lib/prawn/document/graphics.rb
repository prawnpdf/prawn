require "enumerator"

module Prawn
  class Document

    # Implements the drawing facilities for Prawn::Document  Use this to draw
    # the most beautiful imagineable things.
    #
    module Graphics

      def line(*points)
        x0,y0,x1,y1 = points.flatten
        move_to(x0, y0)
        line_to(x1, y1)
      end

      def line_to(x, y)
        add_content("%.3f %.3f l" % [ x, y ]) 
        stroke
      end

      def polygon(*points)
        (points << points[0]).each_cons(2) do |p1,p2|
          move_to(*p1)
          line_to(*p2)
        end
      end

      def rectangle(point,width,height)
        x,y = point
        polygon [x        , y         ],
                [x + width, y         ], 
                [x + width, y - height],
                [        x, y - height]

      end

    end
  end
end
