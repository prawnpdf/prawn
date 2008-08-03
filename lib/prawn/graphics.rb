# encoding: utf-8

# graphics.rb : Implements PDF drawing primitives
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require "enumerator"
require "prawn/graphics/cell"

module Prawn

  # Implements the drawing facilities for Prawn::Document.  
  # Use this to draw the most beautiful imaginable things.
  # 
  # This file lifts and modifies several of PDF::Writer's graphics functions
  # ruby-pdf.rubyforge.org
  #
  module Graphics 
      
      
    #######################################################################
    # Low level drawing operations must translate to absolute coords!     #
    #######################################################################
       
    # Moves the drawing position to a given point.  The point can be
    # specified as a tuple or a flattened argument list
    #
    #   pdf.move_to [100,50]
    #   pdf.move_to(100,50)
    #
    def move_to(*point)
      x,y = translate(point)           
      add_content("%.3f %.3f m" % [ x, y ])
    end
    
    # Draws a line from the current drawing position to the specified point.
    # The destination may be described as a tuple or a flattened list:    
    #
    #   pdf.line_to [50,50] 
    #   pdf.line_to(50,50)    
    #
    def line_to(*point)      
      x,y = translate(point)
      add_content("%.3f %.3f l" % [ x, y ]) 
    end    
    
    # Draws a Bezier curve from the current drawing position to the 
    # specified point, bounded by two additional points.
    #  
    #   pdf.curve_to [100,100], :bounds => [[90,90],[75,75]]   
    #
    def curve_to(dest,options={})                           
       options[:bounds] or raise Prawn::Errors::InvalidGraphicsPath, 
         "Bounding points for bezier curve must be specified "+
         "as :bounds => [[x1,y1],[x2,y2]]"       

       curve_points = (options[:bounds] << dest).map { |e| translate(e) }
       add_content("%.3f %.3f %.3f %.3f %.3f %.3f c" % 
                     curve_points.flatten )    
    end   
    
    # Draws a rectangle given <tt>point</tt>, <tt>width</tt> and 
    # <tt>height</tt>.  The rectangle is bounded by its upper-left corner.
    #
    #    pdf.rectangle [300,300], 100, 200
    # 
    def rectangle(point,width,height)
      x,y = translate(point)
      add_content("%.3f %.3f %.3f %.3f re" % [ x, y - height, width, height ])      
    end
       
    ###########################################################
    #  Higher level functions: May use relative coords        #   
    ########################################################### 
      
    # Sets line thickness to the <tt>width</tt> specified.
    #
    def line_width=(width)
      @line_width = width
      add_content("#{width} w")
    end

    # The current line thickness
    #
    def line_width
      @line_width || 1
    end
       
    # Draws a line from one point to another. Points may be specified as 
    # tuples or flattened argument list:
    #
    #   pdf.line [100,100], [200,250] 
    #   pdf.line(100,100,200,250)
    #
    def line(*points)
      x0,y0,x1,y1 = points.flatten
      move_to(x0, y0)
      line_to(x1, y1)
    end   

    # Draws a horizontal line from <tt>x1</tt> to <tt>x2</tt> at the
    # current <tt>y</tt> position.
    #
    def horizontal_line(x1,x2)
      line(x1,y,x2,y)
    end

    # Draws a horizontal line from the left border to the right border of the
    # bounding box at the current <tt>y</tt> position.
    #
    def horizontal_rule
      horizontal_line(bounds.left, bounds.right)
    end

    # Draws a vertical line at the given x position from y1 to y2.
    # 
    def vertical_line_at(x,y1,y2)
      line(x,y1,x,y2)
    end
               
    # Draws a Bezier curve between two points, bounded by two additional
    # points
    #
    #    pdf.curve [50,100], [100,100], :bounds => [[90,90],[75,75]]  
    #
    def curve(origin,dest, options={})
      move_to *origin    
      curve_to(dest,options)
    end

    # This constant is used to approximate a symmetrical arc using a cubic
    # Bezier curve.   
    #
    KAPPA = 4.0 * ((Math.sqrt(2) - 1.0) / 3.0)
                                                                  
    # Draws a circle of radius <tt>:radius</tt> with the centre-point at <tt>point</tt>
    # as a complete subpath. The drawing point will be moved to the
    # centre-point upon completion of the drawing the circle.     
    #                                           
    #    pdf.circle_at [100,100], :radius => 25  
    #
    def circle_at(point, options)  
      x,y = point
      ellipse_at [x, y], options[:radius]     
    end 
      
    # Draws an ellipse of +x+ radius <tt>r1</tt> and +y+ radius <tt>r2</tt>
    # with the centre-point at <tt>point</tt> as a complete subpath. The
    # drawing point will be moved to the centre-point upon completion of the
    # drawing the ellipse.   
    #                                    
    #    # draws an ellipse with x-radius 25 and y-radius 50
    #    pdf.ellipse_at [100,100], 25, 50   
    #
    def ellipse_at(point, r1, r2 = r1)  
      x, y = point
      l1 = r1 * KAPPA
      l2 = r2 * KAPPA            
      
      move_to(x + r1, y)
      
      # Upper right hand corner
      curve_to [x,  y + r2], 
        :bounds => [[x + r1, y + l1], [x + l2, y + r2]]

      # Upper left hand corner                          
      curve_to [x - r1, y],  
        :bounds => [[x - l2, y + r2], [x - r1, y + l1]] 
 
      # Lower left hand corner
      curve_to [x, y - r2],  
        :bounds => [[x - r1, y - l1], [x - l2, y - r2]]  

      # Lower right hand corner
      curve_to [x + r1, y],
        :bounds => [[x + l2, y - r2], [x + r1, y - l1]]    
   
      move_to(x, y)
    end
     
    # Draws a polygon from the specified points.
    #                                              
    #    # draws a snazzy triangle
    #    pdf.polygon [100,100], [100,200], [200,200]  
    #
    def polygon(*points) 
      move_to points[0]
      (points << points[0]).each_cons(2) do |p1,p2|
        line_to(*p2)
      end
    end
                                      
    # Sets the fill color.  6 digit HTML color codes are used.
    # 
    #   pdf.fill_color "f0ffc1"
    #
    def fill_color(color=nil)
      return @fill_color unless color
      @fill_color = color
      set_fill_color     
    end 
    
    alias_method :fill_color=, :fill_color                                                                     
    
    # Sets the line stroking color.  6 digit HTML color codes are used.
    #
    #   pdf.stroke_color "cc2fde"
    #
    def stroke_color(color=nil) 
      return @stroke_color unless color
      @stroke_color = color
      set_stroke_color
    end   
    
    alias_method :stroke_color=, :stroke_color
    
    # Strokes and closes the current path.
    #
    def stroke
      yield if block_given?
      add_content "S"
    end

    # Fills and closes the current path
    #
    def fill               
      yield if block_given?
      add_content "f"
    end
    
    # Fills, strokes, and closes the current path.
    #
    def fill_and_stroke  
      yield if block_given?
      add_content "b" 
    end     
    
    # Provides the following shortcuts:
    #
    #    stroke_some_method(*args) #=> some_method(*args); stroke
    #    fill_some_method(*args) #=> some_method(*args); fill
    #
    def method_missing(id,*args,&block)
      case(id.to_s) 
      when /^fill_and_stroke_(.*)/
        send($1,*args,&block); fill_and_stroke
      when /^stroke_(.*)/
        send($1,*args,&block); stroke 
      when /^fill_(.*)/
        send($1,*args,&block); fill
      else
        super
      end
    end                    
    
    private    
    
    def translate(*point)
      x,y = point.flatten
      [@bounding_box.absolute_left + x, @bounding_box.absolute_bottom + y]
    end     
                                                                        
    def set_fill_color
      r,g,b = [@fill_color[0..1], @fill_color[2..3], @fill_color[4..5]].
              map { |e| e.to_i(16) }       
      add_content "%.3f %.3f %.3f rg" %  [r / 255.0, g / 255.0, b / 255.0]   
    end
    
    def set_stroke_color
      r,g,b = [@stroke_color[0..1], @stroke_color[2..3], @stroke_color[4..5]].
              map { |e| e.to_i(16) }     
      add_content "%.3f %.3f %.3f RG" %  [r / 255.0, g / 255.0, b / 255.0]       
    end                                       
    
    def update_colors 
      @fill_color   ||= "000000"
      @stroke_color ||= "000000"                                       
      set_fill_color
      set_stroke_color
    end

  end
end
