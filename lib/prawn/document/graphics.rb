require "enumerator"

module Prawn
  class Document

     # Implements the drawing facilities for Prawn::Document  Use this to draw
     # the most beautiful imagineable things.
     # 
     # This file lifts and modifies several of PDF::Writer's graphics functions
     # ruby-pdf.rubyforge.org
     #
     module Graphics
       
       def line_width=(width)
         add_content("#{width} w")
       end
 
       def line(*points)
         x0,y0,x1,y1 = points.flatten
         move_to(x0, y0)
         line_to(x1, y1)
       end   
 
       def line_to(x, y)
         add_content("%.3f %.3f l" % [ x, y ]) 
         stroke
       end
   
       def curve_to(dest,options={})                           
         options[:bounds] or raise Prawn::Errors::InvalidGraphicsPath, 
           "Bounding points for bezier curve must be specified "+
           "as :bounds => [[x1,y1],[x2,y2]]"
         add_content("%.3f %.3f %.3f %.3f %.3f %.3f c" % 
                       (options[:bounds] + dest).flatten )    
         stroke
      end    
 
      def curve(origin,dest, options={})
        move_to *origin    
        curve_to(dest,options)
      end
 
      # This constant is used to approximate a symmetrical arc using a cubic
      # Bezier curve.   
      #
      KAPPA = 4.0 * ((Math.sqrt(2) - 1.0) / 3.0)
                                                                    
      # Draws a circle of radius +r+ with the centre-point at <tt>point</tt>
      # as a complete subpath. The drawing point will be moved to the
      # centre-point upon completion of the drawing the circle.
      def circle_at(point, options)  
        x,y = point
        ellipse_at [x, y], options[:radius]     
      end 
        
      # Draws an ellipse of +x+ radius <tt>r1</tt> and +y+ radius <tt>r2</tt>
      # with the centre-point at <tt>point</tt> as a complete subpath. The
      # drawing point will be moved to the centre-point upon completion of the
      # drawing the ellipse.   
      #
      def ellipse_at(point, r1, r2 = r1)  
        x, y = point
        l1 = r1 * KAPPA
        l2 = r2 * KAPPA
        # Upper right hand corner
        curve [x + r1, y], [x,  y + r2], 
          :bounds => [[x + r1, y + l1], [x + l2, y + r2]]
 
        # Upper left hand corner                          
        curve [x,y + r2], [x - r1, y],  
          :bounds => [[x - l2, y + r2], [x - r1, y + l1]] 
   
        # Lower left hand corner
        curve [x - r1, y], [x, y - r2],  
          :bounds => [[x - r1, y - l1], [x - l2, y - r2]]  
 
        # Lower right hand corner
        curve [x, y - r2], [x + r1, y],
          :bounds => [[x + l2, y - r2], [x + r1, y - l1]]    
     
        move_to(x, y)
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