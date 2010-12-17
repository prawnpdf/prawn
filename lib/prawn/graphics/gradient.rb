# encoding: utf-8

# gradient.rb : Implements axial gradient
#
# Contributed by Wojciech Piekutowski. November, 2009
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
module Prawn
  module Graphics
    module Gradient
      # Sets the fill gradient from color1 to color2.
      #
      # It accepts CMYK and RGB colors, like #fill_color. Both colors must be
      # of the same type.
      #
      # point, width and height define a bounding box in which the gradient
      # will be rendered. For example, if you want to have page full of text
      # with gradually changing color:
      #
      #   pdf.fill_gradient [0, pdf.bounds.height], pdf.bounds.width,
      #     pdf.bounds.height, 'FF0000', '0000FF'
      #   pdf.text 'lots of text'*1000
      #
      # <tt>:stroke_bounds</tt> - draw gradient bounds
      def fill_gradient(point, width, height, color1, color2, options = {})
        set_gradient(:fill, point, width, height, color1, color2, options)
      end

      # Sets the stroke gradient from color1 to color2.
      #
      # See #fill_gradient for details.
      def stroke_gradient(point, width, height, color1, color2, options = {})
        set_gradient(:stroke, point, width, height, color1, color2, options)
      end

      private

      def set_gradient(type, point, width, height, color1, color2, options)
        if options[:stroke_bounds]
          stroke_color 0, 0, 0, 100
          stroke_rectangle point, width, height
        end

        if color_type(color1) != color_type(color2)
          raise ArgumentError, 'both colors must be of the same type: RGB or CMYK'
        end

        process_color color1
        process_color color2

        shader = ref!({
          :FunctionType => 2,
          :Domain => [0.0, 1.0],
          :C0 => normalize_color(color1),
          :C1 => normalize_color(color2),
          :N => 1,
        })

        shading = ref!({
          :ShadingType => 2, # axial shading
          :ColorSpace => color_type(color1) == :RGB ? :DeviceRGB : :DeviceCMYK,
          :Coords => [0.0, 0.0, 1.0, 0.0],
          :Function => shader,
          :Extend => [true, true],
        })

        x, y = *point
        shading_pattern = ref!({
          :PatternType => 2, # shading pattern
          :Shading => shading,
          :Matrix => [0,-height, -width, 0, x, y],
        })

        patterns = page.resources[:Pattern] ||= {}
        id = patterns.empty? ? 'SP1' : patterns.keys.sort.last.succ
        patterns[id] = shading_pattern

        set_color type, id, :pattern => true
      end
    end
  end
end

