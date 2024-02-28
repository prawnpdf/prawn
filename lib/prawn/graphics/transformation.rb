# frozen_string_literal: true

module Prawn
  module Graphics
    # Implements user-space coordinate transformation.
    module Transformation
      # @group Stable API

      # Rotate the user space. If a block is not provided, then you must save
      # and restore the graphics state yourself.
      #
      # @example
      #   save_graphics_state
      #   rotate 30
      #   text "rotated text"
      #   restore_graphics_state
      #
      # @example Rotating a rectangle around its upper-left corner
      #   x = 300
      #   y = 300
      #   width = 150
      #   height = 200
      #   angle = 30
      #   pdf.rotate(angle, :origin => [x, y]) do
      #     pdf.stroke_rectangle([x, y], width, height)
      #   end
      #
      # @param angle [Number] Angle in degrees.
      # @param options [Hash{Symbol => any}]
      # @option options :origin [Array(Number, Number)] Rotation origin point.
      #   A block must be provided if specified.
      # @yield
      # @raise [Prawn::Errors::BlockRequired] if an `:origin` option is
      #   provided, but no block is given.
      # @return [void]
      def rotate(angle, options = {}, &block)
        Prawn.verify_options(:origin, options)
        rad = degree_to_rad(angle)
        cos = Math.cos(rad)
        sin = Math.sin(rad)
        if options[:origin].nil?
          transformation_matrix(cos, sin, -sin, cos, 0, 0, &block)
        else
          raise Prawn::Errors::BlockRequired unless block

          x = options[:origin][0] + bounds.absolute_left
          y = options[:origin][1] + bounds.absolute_bottom
          x_prime = (x * cos) - (y * sin)
          y_prime = (x * sin) + (y * cos)
          translate(x - x_prime, y - y_prime) do
            transformation_matrix(cos, sin, -sin, cos, 0, 0, &block)
          end
        end
      end

      # Translate the user space. If a block is not provided, then you must
      # save and restore the graphics state yourself.
      #
      # @example Move the text up and over 10
      #   save_graphics_state
      #   translate(10, 10)
      #   text "scaled text"
      #   restore_graphics_state
      #
      # @example draw a rectangle with its upper-left corner at x + 10, y + 10
      #   x = 300
      #   y = 300
      #   width = 150
      #   height = 200
      #   pdf.translate(10, 10) do
      #     pdf.stroke_rectangle([x, y], width, height)
      #   end
      #
      # @param x [Number]
      # @param y [Number]
      # @yield
      # @return [void]
      def translate(x, y, &block)
        transformation_matrix(1, 0, 0, 1, x, y, &block)
      end

      # Scale the user space. If a block is not provided, then you must save
      # and restore the graphics state yourself.
      #
      # @example
      #   save_graphics_state
      #   scale 1.5
      #   text "scaled text"
      #   restore_graphics_state
      #
      # @example Scale a rectangle from its upper-left corner
      #   x = 300
      #   y = 300
      #   width = 150
      #   height = 200
      #   factor = 1.5
      #   pdf.scale(angle, :origin => [x, y]) do
      #     pdf.stroke_rectangle([x, y], width, height)
      #   end
      #
      # @param factor [Number] Scale factor.
      # @param options [Hash{Symbol => any}]
      # @option options :origin [Array(Number, Number)] The point from which to
      #   scale. A block must be provided if specified.
      # @yield
      # @raise [Prawn::Errors::BlockRequired] If an `:origin` option is
      #   provided, but no block is given.
      # @return [void]
      def scale(factor, options = {}, &block)
        Prawn.verify_options(:origin, options)
        if options[:origin].nil?
          transformation_matrix(factor, 0, 0, factor, 0, 0, &block)
        else
          raise Prawn::Errors::BlockRequired unless block

          x = options[:origin][0] + bounds.absolute_left
          y = options[:origin][1] + bounds.absolute_bottom
          x_prime = factor * x
          y_prime = factor * y
          translate(x - x_prime, y - y_prime) do
            transformation_matrix(factor, 0, 0, factor, 0, 0, &block)
          end
        end
      end

      # The following definition of skew would only work in a clearly
      # predicatable manner when if the document had no margin. don't provide
      # this shortcut until it behaves in a clearly understood manner
      #
      # def skew(a, b, &block)
      #   transformation_matrix(1,
      #                         Math.tan(degree_to_rad(a)),
      #                         Math.tan(degree_to_rad(b)),
      #                         1, 0, 0, &block)
      # end

      # Transform the user space (see notes for rotate regarding graphics state)
      # Generally, one would use the {rotate}, {scale}, and {translate}
      # convenience methods instead of calling transformation_matrix directly
      #
      # @param matrix [Array(Number, Number, Number, Number, Number, Number)]
      #   Transformation matrix.
      #
      #   The six elements correspond to the following elements of the
      #   transformation matrix:
      #
      #   ```plain
      #   a b 0
      #   c d 0
      #   e f 0
      #   ```
      # @yield
      # @return [void]
      def transformation_matrix(*matrix)
        if matrix.length != 6
          raise ArgumentError,
            'Transformation matrix must have exacty 6 elements'
        end
        save_graphics_state if block_given?

        add_to_transformation_stack(*matrix)

        values = PDF::Core.real_params(matrix)
        renderer.add_content("#{values} cm")
        if block_given?
          yield
          restore_graphics_state
        end
      end
    end
  end
end
