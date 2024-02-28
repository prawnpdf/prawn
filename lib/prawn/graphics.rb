# frozen_string_literal: true

# graphics.rb : Implements PDF drawing primitives
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require_relative 'graphics/blend_mode'
require_relative 'graphics/color'
require_relative 'graphics/dash'
require_relative 'graphics/cap_style'
require_relative 'graphics/join_style'
require_relative 'graphics/transparency'
require_relative 'graphics/transformation'
require_relative 'graphics/patterns'

module Prawn
  # Implements the drawing facilities for {Prawn::Document}.
  # Use this to draw the most beautiful imaginable things.
  module Graphics
    include BlendMode
    include Color
    include Dash
    include CapStyle
    include JoinStyle
    include Transparency
    include Transformation
    include Patterns

    # @group Stable API

    #######################################################################
    # Low level drawing operations must map the point to absolute coords! #
    #######################################################################

    # Moves the drawing position to a given point. The point can be specified as
    # a tuple or a flattened argument list.
    #
    # @example
    #   pdf.move_to [100, 50]
    #   pdf.move_to(100, 50)
    #
    # @overload move_to(point)
    #   @param point [Array(Number, Number)]
    #   @return [void]
    # @overload move_to(x, y)
    #   @param x [Number]
    #   @param y [Number]
    #   @return [void]
    def move_to(*point)
      xy = PDF::Core.real_params(map_to_absolute(point))
      renderer.add_content("#{xy} m")
    end

    # Draws a line from the current drawing position to the specified point.
    # The destination may be described as a tuple or a flattened list:
    #
    # @example
    #   pdf.line_to [50, 50]
    #   pdf.line_to(50, 50)
    #
    # @overload line_to(point)
    #   @param point [Array(Number, Number)]
    #   @return [void]
    # @overload line_to(x, y)
    #   @param x [Number]
    #   @param y [Number]
    #   @return [void]
    def line_to(*point)
      xy = PDF::Core.real_params(map_to_absolute(point))
      renderer.add_content("#{xy} l")
    end

    # Draws a Bezier curve from the current drawing position to the
    # specified point, bounded by two additional points.
    #
    # @example
    #   pdf.curve_to [100, 100], bounds: [[90, 90], [75, 75]]
    #
    # @param dest [Array(Number, Number)]
    # @param options [Hash]
    # @option options :bounds [Array(Array(Number, Number), Array(Number, Number))]
    # @return [void]
    def curve_to(dest, options = {})
      options[:bounds] || raise(
        Prawn::Errors::InvalidGraphicsPath,
        'Bounding points for bezier curve must be specified as :bounds => [[x1,y1],[x2,y2]]',
      )

      curve_points = PDF::Core.real_params(
        (options[:bounds] << dest).flat_map { |e| map_to_absolute(e) },
      )

      renderer.add_content("#{curve_points} c")
    end

    # Draws a rectangle given `point`, `width and `height`. The rectangle is
    # bounded by its upper-left corner.
    #
    # @example
    #    pdf.rectangle [300, 300], 100, 200
    #
    # @param point [Array(Number, Number)]
    # @param width [Number]
    # @param height [Number]
    # @return [void]
    def rectangle(point, width, height)
      x, y = map_to_absolute(point)
      box = PDF::Core.real_params([x, y - height, width, height])

      renderer.add_content("#{box} re")
    end

    # Draws a rounded rectangle given `point`, `width`, `height`, and `radius`
    # for the rounded corner. The rectangle is bounded by its upper-left corner.
    #
    # @example
    #    pdf.rounded_rectangle [300, 300], 100, 200, 10
    #
    # @param point [Array(Number, Number)]
    # @param width [Number]
    # @param height [Number]
    # @param radius [Number]
    # @return [void]
    def rounded_rectangle(point, width, height, radius)
      x, y = point
      rounded_polygon(
        radius, point, [x + width, y], [x + width, y - height], [x, y - height],
      )
    end

    ###########################################################
    #  Higher level functions: May use relative coords        #
    ###########################################################

    # Sets line thickness to the `width` specified.
    #
    # @param width [Number]
    # @return [void]
    def line_width=(width)
      self.current_line_width = width
      write_line_width
    end

    # When called without an argument, returns the current line thickness.
    # When called with an argument, sets the line thickness to the specified
    # value (in PDF points).
    #
    # @example
    #   pdf.line_width #=> 1
    #   pdf.line_width(5)
    #   pdf.line_width #=> 5
    #
    # @overload line_width()
    #   @return [Number]
    # @overload line_width(width)
    #   @param width [Number]
    #   @return [void]
    def line_width(width = nil)
      if width
        self.line_width = width
      else
        current_line_width
      end
    end

    # Draws a line from one point to another. Points may be specified as
    # tuples or flattened argument list.
    #
    # @example
    #   pdf.line [100, 100], [200, 250]
    #   pdf.line(100, 100, 200, 250)
    #
    # @overload line(point1, point2)
    #   @param point1 [Array(Number, Number)]
    #   @param point2 [Array(Number, Number)]
    #   @return [void]
    # @overload line(x1, y1, x2, y2)
    #   @param x1 [Number]
    #   @param y1 [Number]
    #   @param x2 [Number]
    #   @param y2 [Number]
    #   @return [void]
    def line(*points)
      x0, y0, x1, y1 = points.flatten
      move_to(x0, y0)
      line_to(x1, y1)
    end

    # Draws a horizontal line from `x1` to `x2` at the current {Document#y}
    # position, or the position specified by the `:at` option.
    #
    # @example Draw a line from `[25, 75]` to `[100, 75]`
    #  horizontal_line 25, 100, at: 75
    #
    # @param x1 [Number]
    # @param x2 [Number]
    # @param options [Hash]
    # @option options :at [Number]
    # @return [void]
    def horizontal_line(x1, x2, options = {})
      y1 = options[:at] || (y - bounds.absolute_bottom)

      line(x1, y1, x2, y1)
    end

    # Draws a horizontal line from the left border to the right border of the
    # bounding box at the current {Document#y} position.
    #
    # @return [void]
    def horizontal_rule
      horizontal_line(bounds.left, bounds.right)
    end

    # Draws a vertical line at the x coordinate given by `:at` from `y1` to
    # `y2`.
    #
    # @example Draw a line from `[25, 100]` to `[25, 300]`
    #   vertical_line 100, 300, at: 25
    #
    # @param y1 [Number]
    # @param y2 [Number]
    # @param params [Hash]
    # @option params :at [Number]
    # @return [void]
    def vertical_line(y1, y2, params)
      line(params[:at], y1, params[:at], y2)
    end

    # Draws a Bezier curve between two points, bounded by two additional
    # points
    #
    # @example
    #    pdf.curve [50, 100], [100, 100], bounds: [[90, 90], [75, 75]]
    #
    # @param origin [Array(Number, Number)]
    # @param dest [Array(Number, Number)]
    # @param options [Hash]
    # @option options :bounds [Array(Array(Number, Number), Array(Number, Number))]
    # @return [void]
    def curve(origin, dest, options = {})
      move_to(*origin)
      curve_to(dest, options)
    end

    # This constant is used to approximate a symmetrical arc using a cubic
    # Bezier curve.
    KAPPA = 4.0 * ((Math.sqrt(2) - 1.0) / 3.0)

    # Draws a circle of radius `radius` with the centre-point at
    # `point` as a complete subpath. The drawing point will be moved to
    # the centre-point upon completion of the drawing the circle.
    #
    # @example
    #    pdf.circle [100, 100], 25
    #
    # @param center [Array(Number, Number)]
    # @param radius [Number]
    # @return [void]
    def circle(center, radius)
      ellipse(center, radius, radius)
    end

    # Draws an ellipse of `x` radius `radius1` and `y` radius `radius2` with the
    # centre-point at `point` as a complete subpath. The drawing point will be
    # moved to the centre-point upon completion of the drawing the ellipse.
    #
    # @example Draws an ellipse with x-radius 25 and y-radius 50
    #    pdf.ellipse [100, 100], 25, 50
    #
    # @param point [Array(Number, Number)]
    # @param radius1 [Number]
    # @param radius2 [Number]
    # @return [void]
    def ellipse(point, radius1, radius2 = radius1)
      x, y = point
      l1 = radius1 * KAPPA
      l2 = radius2 * KAPPA

      move_to(x + radius1, y)

      # Upper right hand corner
      curve_to(
        [x, y + radius2],
        bounds: [[x + radius1, y + l2], [x + l1, y + radius2]],
      )

      # Upper left hand corner
      curve_to(
        [x - radius1, y],
        bounds: [[x - l1, y + radius2], [x - radius1, y + l2]],
      )

      # Lower left hand corner
      curve_to(
        [x, y - radius2],
        bounds: [[x - radius1, y - l2], [x - l1, y - radius2]],
      )

      # Lower right hand corner
      curve_to(
        [x + radius1, y],
        bounds: [[x + l1, y - radius2], [x + radius1, y - l2]],
      )

      move_to(x, y)
    end

    # Draws a polygon from the specified points.
    #
    # @example Draws a snazzy triangle
    #    pdf.polygon [100,100], [100,200], [200,200]
    #
    # @param points [Array<Array(Number, Number)>]
    # @return [void]
    def polygon(*points)
      move_to(points[0])
      (points[1..] << points[0]).each do |point|
        line_to(*point)
      end
      # close the path
      renderer.add_content('h')
    end

    # Draws a rounded polygon from specified points using the radius to define
    # bezier curves.
    #
    # @example Draws a rounded filled in polygon
    #   pdf.fill_and_stroke_rounded_polygon(
    #     10, [100, 250], [200, 300], [300, 250], [300, 150], [200, 100],
    #     [100, 150]
    #   )
    #
    # @param radius [Number]
    # @param points [Array<Array(Number, Number)>]
    # @return [void]
    def rounded_polygon(radius, *points)
      move_to(point_on_line(radius, points[1], points[0]))
      sides = points.size
      points << points[0] << points[1]
      sides.times do |i|
        rounded_vertex(radius, points[i], points[i + 1], points[i + 2])
      end
      # close the path
      renderer.add_content('h')
    end

    # Creates a rounded vertex for a line segment used for building a rounded
    # polygon requires a radius to define bezier curve and three points. The
    # first two points define the line segment and the third point helps define
    # the curve for the vertex.
    #
    # @param radius [Number]
    # @param points [Array(Array(Number, Number), Array(Number, Number), Array(Number, Number))]
    # @return [void]
    def rounded_vertex(radius, *points)
      radial_point1 = point_on_line(radius, points[0], points[1])
      bezier_point1 = point_on_line(
        (radius - (radius * KAPPA)),
        points[0],
        points[1],
      )
      radial_point2 = point_on_line(radius, points[2], points[1])
      bezier_point2 = point_on_line(
        (radius - (radius * KAPPA)),
        points[2],
        points[1],
      )
      line_to(radial_point1)
      curve_to(radial_point2, bounds: [bezier_point1, bezier_point2])
    end

    # Strokes the current path. If a block is provided, yields to the block
    # before closing the path. See {Graphics::Color} for color details.
    #
    # @yield
    # @return [void]
    def stroke
      yield if block_given?
      renderer.add_content('S')
    end

    # Closes and strokes the current path. If a block is provided, yields to the
    # block before closing the path. See {Graphics::Color} for color details.
    #
    # @yield
    # @return [void]
    def close_and_stroke
      yield if block_given?
      renderer.add_content('s')
    end

    # Draws and strokes a rectangle represented by the current bounding box.
    #
    # @return [void]
    def stroke_bounds
      stroke_rectangle(bounds.top_left, bounds.width, bounds.height)
    end

    # Draws and strokes X and Y axes rulers beginning at the current bounding
    # box origin (or at a custom location).
    #
    # @param options [Hash]
    # @option options :at [Array(Number, Number)] ([0, 0], origin of the bounding box)
    #   Origin of the X and Y axes.
    # @option options :width [Number] (width of the bounding box)
    #   Length of the X axis.
    # @option options :height [Number] (height of the bounding box)
    #   Length of the Y axis.
    # @option options :step_length [Number] (100)
    #   Length of the step between markers.
    # @option options :negative_axes_length [Number] (20)
    #   Length of the negative parts of the axes.
    # @option options :color [String, Array<Number>]
    #   The color of the axes and the text.
    # @return [void]
    def stroke_axis(options = {})
      options = {
        at: [0, 0],
        height: bounds.height - (options[:at] || [0, 0])[1],
        width: bounds.width - (options[:at] || [0, 0])[0],
        step_length: 100,
        negative_axes_length: 20,
        color: '000000',
      }.merge(options)

      Prawn.verify_options(
        %i[at width height step_length negative_axes_length color],
        options,
      )

      save_graphics_state do
        fill_color(options[:color])
        stroke_color(options[:color])

        dash(1, space: 4)
        stroke_horizontal_line(
          options[:at][0] - options[:negative_axes_length],
          options[:at][0] + options[:width],
          at: options[:at][1],
        )
        stroke_vertical_line(
          options[:at][1] - options[:negative_axes_length],
          options[:at][1] + options[:height],
          at: options[:at][0],
        )
        undash

        fill_circle(options[:at], 1)

        (options[:step_length]..options[:width])
          .step(options[:step_length]) do |point|
          fill_circle([options[:at][0] + point, options[:at][1]], 1)
          draw_text(
            point,
            at: [options[:at][0] + point - 5, options[:at][1] - 10],
            size: 7,
          )
        end

        (options[:step_length]..options[:height])
          .step(options[:step_length]) do |point|
          fill_circle([options[:at][0], options[:at][1] + point], 1)
          draw_text(
            point,
            at: [options[:at][0] - 17, options[:at][1] + point - 2],
            size: 7,
          )
        end
      end
    end

    # Closes and fills the current path. See {Graphics::Color} for color details.
    #
    # If the option `fill_rule: :even_odd` is specified, Prawn will use the
    # even-odd rule to fill the path. Otherwise, the nonzero winding number rule
    # will be used. See the PDF reference, "Graphics -> Path Construction and
    # Painting -> Clipping Path Operators" for details on the difference.
    #
    # @param options [Hash]
    # @option options :fill_rule [Symbol]
    # @yield
    # @return [void]
    def fill(options = {})
      yield if block_given?
      renderer.add_content(options[:fill_rule] == :even_odd ? 'f*' : 'f')
    end

    # Closes, fills, and strokes the current path. If a block is provided,
    # yields to the block before closing the path. See {Graphics::Color} for
    # color details.
    #
    # If the option `fill_rule: :even_odd` is specified, Prawn will use the
    # even-odd rule to fill the path. Otherwise, the nonzero winding number rule
    # will be used. See the PDF reference, "Graphics -> Path Construction and
    # Painting -> Clipping Path Operators" for details on the difference.
    #
    # @param options [Hash]
    # @option options :fill_rule [Symbol]
    # @yield
    # @return [void]
    def fill_and_stroke(options = {})
      yield if block_given?
      renderer.add_content(options[:fill_rule] == :even_odd ? 'b*' : 'b')
    end

    # Closes the current path.
    #
    def close_path
      renderer.add_content('h')
    end

    # @!method fill_rectangle(point, width, height)
    #   Draws and fills a rectangle given `point`, `width`, and `height`. The
    #   rectangle is bounded by its upper-left corner.
    #
    #   @param point [Array(Number, Number)]
    #   @param width [Number]
    #   @param height [Number]
    #   @return [void]

    # @!method stroke_rectangle(point, width, height)
    #   Draws and strokes a rectangle given `point`, `width`, and `height`. The
    #   rectangle is bounded by its upper-left corner.
    #
    #   @param point [Array(Number, Number)]
    #   @param width [Number]
    #   @param height [Number]
    #   @return [void]

    # @!method fill_and_stroke_rectangle(point, width, height)
    #   Draws, fills, and strokes a rectangle given `point`, `width`, and
    #   `height`. The rectangle is bounded by its upper-left corner.
    #
    #   @param point [Array(Number, Number)]
    #   @param width [Number]
    #   @param height [Number]
    #   @return [void]

    # @!method fill_rounded_rectangle(point, width, height, radius)
    #
    #   Draws and fills a rounded rectangle given `point`, `width` and `height`,
    #   and `radius` for the rounded corner. The rectangle is bounded by its
    #   upper-left corner.
    #
    #   @param point [Array(Number, Number)]
    #   @param width [Number]
    #   @param height [Number]
    #   @param radius [Number]
    #   @return [void]

    # @!method stroke_rounded_rectangle(point, width, height, radius)
    #   Draws and strokes a rounded rectangle given `point`, `width` and
    #   `height`, and `radius` for the rounded corner. The rectangle is bounded
    #   by its upper-left corner.
    #
    #   @param point [Array(Number, Number)]
    #   @param width [Number]
    #   @param height [Number]
    #   @param radius [Number]
    #   @return [void]

    # @!method fill_and_stroke_rounded_rectangle(point, width, height, radius)
    #
    #   Draws, fills, and strokes a rounded rectangle given `point`, `width`,
    #   and `height` and `radius` for the rounded corner. The rectangle is
    #   bounded by its upper-left corner.
    #
    #   @param point [Array(Number, Number)]
    #   @param width [Number]
    #   @param height [Number]
    #   @param radius [Number]
    #   @return [void]

    # @!method stroke_line(*points)
    #
    #   Strokes a line from one point to another. Points may be specified as
    #   tuples or flattened argument list.
    #
    #   @overload line(point1, point2)
    #     @param point1 [Array(Number, Number)]
    #     @param point2 [Array(Number, Number)]
    #     @return [void]
    #   @overload line(x1, y1, x2, y2)
    #     @param x1 [Number]
    #     @param y1 [Number]
    #     @param x2 [Number]
    #     @param y2 [Number]
    #     @return [void]

    # @!method stroke_horizontal_line(x1, x2, options = {})
    #
    #   Strokes a horizontal line from `x1` to `x2` at the current y position,
    #   or the position specified by the :at option.
    #
    #   @param x1 [Number]
    #   @param x2 [Number]
    #   @param options [Hash]
    #   @option options :at [Number]
    #   @return [void]

    # @!method stroke_horizontal_rule
    #
    #   Strokes a horizontal line from the left border to the right border of
    #   the bounding box at the current y position.
    #
    #   @return [void]

    # @!method stroke_vertical_line(y1, y2, params)
    #
    #   Strokes a vertical line at the x coordinate given by `:at` from `y1` to
    #   `y2`.
    #
    #   @param y1 [Number]
    #   @param y2 [Number]
    #   @param params [Hash]
    #   @option params :at [Number]
    #   @return [void]

    # @!method stroke_curve(origin, dest, options = {})
    #
    #   Strokes a Bezier curve between two points, bounded by two additional
    #   points.
    #
    #   @param origin [Array(Number, Number)]
    #   @param dest [Array(Number, Number)]
    #   @param options [Hash]
    #   @option options :bounds [Array(Array(Number, Number), Array(Number, Number))]
    #   @return [void]

    # @!method: stroke_circle(center, radius)
    #
    #   Draws and strokes a circle of radius `radius` with the centre-point at
    #   `point`.
    #
    #   @param center [Array(Number, Number)]
    #   @param radius [Number]
    #   @return [void]

    # @!method fill_circle(center, radius)
    #
    #   Draws and fills a circle of radius `radius` with the centre-point at
    #   `point`.
    #
    #   @param center [Array(Number, Number)]
    #   @param radius [Number]
    #   @return [void]

    # @!method fill_and_stroke_circle(center, radius)
    #
    #   Draws, strokes, and fills a circle of radius `radius` with the
    #   centre-point at `point`.
    #
    #   @param center [Array(Number, Number)]
    #   @param radius [Number]
    #   @return [void]

    # @!method stroke_ellipse(point, radius1, radius2 = radius1)
    #
    #   Draws and strokes an ellipse of x radius `r1` and y radius `r2` with the
    #   centre-point at `point`.
    #
    #   @param point [Array(Number, Number)]
    #   @param radius1 [Number]
    #   @param radius2 [Number]
    #   @return [void]

    # @!method fill_ellipse(point, radius1, radius2 = radius1)
    #
    #   Draws and fills an ellipse of x radius `r1` and y radius `r2` with the
    #   centre-point at `point`.
    #
    #   @param point [Array(Number, Number)]
    #   @param radius1 [Number]
    #   @param radius2 [Number]
    #   @return [void]

    # @!method fill_and_stroke_ellipse(point, radius1, radius2 = radius1)
    #
    #   Draws, strokes, and fills an ellipse of x radius `r1` and y radius `r2`
    #   with the centre-point at `point`.
    #
    #   @param point [Array(Number, Number)]
    #   @param radius1 [Number]
    #   @param radius2 [Number]
    #   @return [void]

    # @!method stroke_polygon(*points)
    #
    # Draws and strokes a polygon from the specified points.
    #
    #   @param points [Array<Array(Number, Number)>]
    #   @return [void]

    # @!method fill_polygon(*points)
    #
    #   Draws and fills a polygon from the specified points.
    #
    #   @param points [Array<Array(Number, Number)>]
    #   @return [void]

    # @!method fill_and_stroke_polygon(*points)
    #
    #   Draws, strokes, and fills a polygon from the specified points.
    #
    #   @param points [Array<Array(Number, Number)>]
    #   @return [void]

    # @!method stroke_rounded_polygon(radius, *points)
    #
    #   Draws and strokes a rounded polygon from specified points, using
    #   `radius` to define Bezier curves.
    #
    #   @param radius [Number]
    #   @param points [Array<Array(Number, Number)>]
    #   @return [void]

    # @!method fill_rounded_polygon(radius, *points)
    #
    #   Draws and fills a rounded polygon from specified points, using `radius`
    #   to define Bezier curves.
    #
    #   @param radius [Number]
    #   @param points [Array<Array(Number, Number)>]
    #   @return [void]

    # @!method fill_and_stroke_rounded_polygon(radius, *points)
    #
    #   Draws, strokes, and fills a rounded polygon from specified points, using
    #   `radius` to define Bezier curves.
    #
    #   @param radius [Number]
    #   @param points [Array<Array(Number, Number)>]
    #   @return [void]

    ops = %w[fill stroke fill_and_stroke]
    shapes = %w[
      line_to curve_to rectangle rounded_rectangle line horizontal_line
      horizontal_rule vertical_line curve circle_at circle ellipse_at ellipse
      polygon rounded_polygon rounded_vertex
    ]

    ops.product(shapes).each do |operation, shape|
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{operation}_#{shape}(*args)    # def fill_polygon(*args)
          #{shape}(*args)                   #   polygon(*args)
          #{operation}                      #   fill
        end                                 # end
      METHOD
    end

    private

    def current_line_width
      graphic_state.line_width
    end

    def current_line_width=(width)
      graphic_state.line_width = width
    end

    def write_line_width
      renderer.add_content("#{current_line_width} w")
    end

    def map_to_absolute(*point)
      x, y = point.flatten
      [@bounding_box.absolute_left + x, @bounding_box.absolute_bottom + y]
    end

    def map_to_absolute!(point)
      point.replace(map_to_absolute(point))
    end

    def degree_to_rad(angle)
      angle * Math::PI / 180
    end

    # Returns the coordinates for a point on a line that is a given distance
    # away from the second point defining the line segement
    def point_on_line(distance_from_end, *points)
      x0, y0, x1, y1 = points.flatten
      length = Math.sqrt(((x1 - x0)**2) + ((y1 - y0)**2))
      p = (length - distance_from_end) / length
      xr = x0 + (p * (x1 - x0))
      yr = y0 + (p * (y1 - y0))
      [xr, yr]
    end
  end
end
