# encoding: utf-8

# graphics.rb : Implements PDF drawing primitives
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require "enumerator"
require "prawn/graphics/color"

module Prawn

  # Implements the drawing facilities for Prawn::Document.
  # Use this to draw the most beautiful imaginable things.
  #
  # This file lifts and modifies several of PDF::Writer's graphics functions
  # ruby-pdf.rubyforge.org
  #
  module Graphics

    include Color

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

    # When called without an argument, returns the current line thickness.
    # When called with an argument, sets the line thickness to the specified
    # value (in PDF points)
    #
    #   pdf.line_width #=> 1
    #   pdf.line_width(5)
    #   pdf.line_width #=> 5
    #
    def line_width(width=nil)
      if width
        self.line_width = width
      else
        @line_width || 1
      end
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
    # current <tt>y</tt> position, or the position specified by the :at option.
    #
    #  # draw a line from [25, 75] to [100, 75]
    #  horizontal_line 25, 100, :at => 75  
    #
    def horizontal_line(x1,x2,options={})
      if options[:at]
        y1 = options[:at]
      else
        y1 = y - bounds.absolute_bottom
      end
      
      line(x1,y1,x2,y1)
    end

    # Draws a horizontal line from the left border to the right border of the
    # bounding box at the current <tt>y</tt> position.
    #
    def horizontal_rule
      horizontal_line(bounds.left, bounds.right)
    end

    # Draws a vertical line at the x cooordinate given by :at from y1 to y2.
    #
    #   # draw a line from [25, 100] to [25, 300]
    #   vertical_line 100, 300, :at => 25
    #
    def vertical_line(y1,y2,params)
      line(params[:at],y1,params[:at],y2)
    end

    # Draws a Bezier curve between two points, bounded by two additional
    # points
    #
    #    pdf.curve [50,100], [100,100], :bounds => [[90,90],[75,75]]
    #
    def curve(origin,dest, options={})
      move_to(*origin)
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

    # Strokes and closes the current path. See Graphic::Color for color details
    #
    def stroke
      yield if block_given?
      add_content "S"
    end
    
    # Draws and strokes a rectangle represented by the current bounding box
    #
    def stroke_bounds
      stroke_rectangle bounds.top_left, bounds.width, bounds.height
    end

    # Fills and closes the current path. See Graphic::Color for color details
    #
    def fill
      yield if block_given?
      add_content "f"
    end

    # Fills, strokes, and closes the current path. See Graphic::Color for color details
    #
    def fill_and_stroke
      yield if block_given?
      add_content "b"
    end

    private

    def translate(*point)
      x,y = point.flatten
      [@bounding_box.absolute_left + x, @bounding_box.absolute_bottom + y]
    end

    def translate!(point)
      point.replace(translate(point))
    end

  end
end
