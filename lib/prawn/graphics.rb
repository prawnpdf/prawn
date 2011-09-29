# encoding: utf-8

# graphics.rb : Implements PDF drawing primitives
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require "prawn/graphics/color"
require "prawn/graphics/dash"
require "prawn/graphics/cap_style"
require "prawn/graphics/join_style"
require "prawn/graphics/transparency"
require "prawn/graphics/transformation"
require "prawn/graphics/gradient"

module Prawn

  # Implements the drawing facilities for Prawn::Document.
  # Use this to draw the most beautiful imaginable things.
  #
  # This file lifts and modifies several of PDF::Writer's graphics functions
  # ruby-pdf.rubyforge.org
  #
  module Graphics

    include Color
    include Dash
    include CapStyle
    include JoinStyle
    include Transparency
    include Transformation
    include Gradient

    #######################################################################
    # Low level drawing operations must map the point to absolute coords! #
    #######################################################################

    # Moves the drawing position to a given point.  The point can be
    # specified as a tuple or a flattened argument list
    #
    #   pdf.move_to [100,50]
    #   pdf.move_to(100,50)
    #
    def move_to(*point)
      x,y = map_to_absolute(point)
      add_content("%.3f %.3f m" % [ x, y ])
    end

    # Draws a line from the current drawing position to the specified point.
    # The destination may be described as a tuple or a flattened list:
    #
    #   pdf.line_to [50,50]
    #   pdf.line_to(50,50)
    #
    def line_to(*point)
      x,y = map_to_absolute(point)
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

       curve_points = (options[:bounds] << dest).map { |e| map_to_absolute(e) }
       add_content("%.3f %.3f %.3f %.3f %.3f %.3f c" %
                     curve_points.flatten )
    end

    # Draws a rectangle given <tt>point</tt>, <tt>width</tt> and
    # <tt>height</tt>.  The rectangle is bounded by its upper-left corner.
    #
    #    pdf.rectangle [300,300], 100, 200
    #
    def rectangle(point,width,height)
      x,y = map_to_absolute(point)
      add_content("%.3f %.3f %.3f %.3f re" % [ x, y - height, width, height ])
    end
    
    # Draws a rounded rectangle given <tt>point</tt>, <tt>width</tt> and
    # <tt>height</tt> and <tt>radius</tt> for the rounded corner. The rectangle 
    # is bounded by its upper-left corner.
    #
    #    pdf.rounded_rectangle [300,300], 100, 200, 10
    #
    def rounded_rectangle(point,width,height,radius)
      x, y = point
      rounded_polygon(radius, point, [x + width, y], [x + width, y - height], [x, y - height])
    end
    

    ###########################################################
    #  Higher level functions: May use relative coords        #
    ###########################################################

    # Sets line thickness to the <tt>width</tt> specified.
    #
    def line_width=(width)
      self.current_line_width = width
      write_line_width
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
        current_line_width
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

    # <b>DEPRECATED:</b> Please use <tt>circle</tt> instead.
    def circle_at(point, options)
      warn "[DEPRECATION] 'circle_at' is deprecated in favor of 'circle'. " +
           "'circle_at' will be removed in release 1.1"
      circle(point, options[:radius])
    end

    # Draws a circle of radius <tt>radius</tt> with the centre-point at <tt>point</tt>
    # as a complete subpath. The drawing point will be moved to the
    # centre-point upon completion of the drawing the circle.
    #
    #    pdf.circle [100,100], 25
    #
    def circle(center, radius)
      ellipse(center, radius, radius)
    end

    # <b>DEPRECATED:</b> Please use <tt>ellipse</tt> instead.
    def ellipse_at(point, r1, r2=r1)
      warn "[DEPRECATION] 'ellipse_at' is deprecated in favor of 'ellipse'. " +
           "'ellipse_at' will be removed in release 1.1"
      ellipse(point, r1, r2)
    end

    # Draws an ellipse of +x+ radius <tt>r1</tt> and +y+ radius <tt>r2</tt>
    # with the centre-point at <tt>point</tt> as a complete subpath. The
    # drawing point will be moved to the centre-point upon completion of the
    # drawing the ellipse.
    #
    #    # draws an ellipse with x-radius 25 and y-radius 50
    #    pdf.ellipse [100,100], 25, 50
    #
    def ellipse(point, r1, r2 = r1)
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
      (points[1..-1] << points[0]).each do |point|
        line_to(*point)
      end
      # close the path
      add_content "h"
    end
    
    # Draws a rounded polygon from specified points using the radius to define bezier curves
    #
    #  # draws a rounded filled in polygon
    #   pdf.fill_and_stroke_rounded_polygon(10, [100, 250], [200, 300], [300, 250],
    #                 [300, 150], [200, 100], [100, 150])
    def rounded_polygon(radius, *points)
      move_to point_on_line(radius, points[1], points[0])
      sides = points.size
      points << points[0] << points[1]
      (sides).times do |i|
        rounded_vertex(radius, points[i], points[i + 1], points[i + 2])
      end
      # close the path
      add_content "h"
    end
    
    
    # Creates a rounded vertex for a line segment used for building a rounded polygon
    # requires a radius to define bezier curve and three points. The first two points define
    # the line segment and the third point helps define the curve for the vertex.
    def rounded_vertex(radius, *points)
      x0,y0,x1,y1,x2,y2 = points.flatten
      radial_point_1 = point_on_line(radius, points[0], points[1])
      bezier_point_1 = point_on_line((radius - radius*KAPPA), points[0], points[1] )
      radial_point_2 = point_on_line(radius, points[2], points[1])
      bezier_point_2 = point_on_line((radius - radius*KAPPA), points[2], points[1])
      line_to(radial_point_1)
      curve_to(radial_point_2, :bounds => [bezier_point_1, bezier_point_2])
    end      

    # Strokes the current path. If a block is provided, yields to the block
    # before closing the path. See Graphics::Color for color details.
    #
    def stroke
      yield if block_given?
      add_content "S"
    end

    # Closes and strokes the current path. If a block is provided, yields to
    # the block before closing the path. See Graphics::Color for color details.
    #
    def close_and_stroke
      yield if block_given?
      add_content "s"
    end
    
    # Draws and strokes a rectangle represented by the current bounding box
    #
    def stroke_bounds
      stroke_rectangle bounds.top_left, bounds.width, bounds.height
    end

    # Closes and fills the current path. See Graphics::Color for color details.
    #
    # If the option :fill_rule => :even_odd is specified, Prawn will use the
    # even-odd rule to fill the path. Otherwise, the nonzero winding number rule
    # will be used. See the PDF reference, "Graphics -> Path Construction and
    # Painting -> Clipping Path Operators" for details on the difference.
    #
    def fill(options={})
      yield if block_given?
      add_content(options[:fill_rule] == :even_odd ? "f*" : "f")
    end

    # Closes, fills, and strokes the current path. If a block is provided,
    # yields to the block before closing the path. See Graphics::Color for
    # color details.
    #
    # If the option :fill_rule => :even_odd is specified, Prawn will use the
    # even-odd rule to fill the path. Otherwise, the nonzero winding number rule
    # will be used. See the PDF reference, "Graphics -> Path Construction and
    # Painting -> Clipping Path Operators" for details on the difference.
    #
    def fill_and_stroke(options={})
      yield if block_given?
      add_content(options[:fill_rule] == :even_odd ? "b*" : "b")
    end

    # Closes the current path.
    #
    def close_path
      add_content "h"
    end

    # Provides the following shortcuts:
    #
    #    stroke_some_method(*args) #=> some_method(*args); stroke
    #    fill_some_method(*args) #=> some_method(*args); fill
    #    fill_and_stroke_some_method(*args) #=> some_method(*args); fill_and_stroke
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
    
    def current_line_width
      graphic_state.line_width
    end
    
    def current_line_width=(width)
      graphic_state.line_width = width
    end
    
    def write_line_width
      add_content("#{current_line_width} w")
    end

    def map_to_absolute(*point)
      x,y = point.flatten
      [@bounding_box.absolute_left + x, @bounding_box.absolute_bottom + y]
    end

    def map_to_absolute!(point)
      point.replace(map_to_absolute(point))
    end

    def degree_to_rad(angle)
       angle * Math::PI / 180
    end
    
    # Returns the coordinates for a point on a line that is a given distance away from the second
    # point defining the line segement
    def point_on_line(distance_from_end, *points)
      x0,y0,x1,y1 = points.flatten
      length = Math.sqrt((x1 - x0)**2 + (y1 - y0)**2)
      p = (length - distance_from_end) / length
      xr = x0 + p*(x1 - x0)
      yr = y0 + p*(y1 - y0)
      [xr, yr]
    end
    
  end
end
