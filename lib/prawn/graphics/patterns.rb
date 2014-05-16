# encoding: utf-8

# patterns.rb : Implements axial & radial gradients
#
# Originally implemented by Wojciech Piekutowski. November, 2009
# Copyright September 2012, Alexander Mankuta. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
module Prawn
  module Graphics
    module Patterns
      # @group Stable API

      # Sets the fill gradient from color1 to color2.
      # old arguments: point, width, height, color1, color2, options = {}
      # new arguments: from, to, color1, color1
      #            or  from, r1, to, r2, color1, color2
      def fill_gradient(*args)
        set_gradient(:fill, *args)
      end

      # Sets the stroke gradient from color1 to color2.
      # old arguments: point, width, height, color1, color2, options = {}
      # new arguments: from, to, color1, color2
      #            or  from, r1, to, r2, color1, color2
      def stroke_gradient(*args)
        set_gradient(:stroke, *args)
      end

      private

      def set_gradient(type, *grad)
        patterns = page.resources[:Pattern] ||= {}

        registry_key = gradient_registry_key grad

        if patterns["SP#{registry_key}"]
          shading = patterns["SP#{registry_key}"]
        else
          unless shading = gradient_registry[registry_key]
            shading = gradient(*grad)
            gradient_registry[registry_key] = shading
          end

          patterns["SP#{registry_key}"] = shading
        end

        operator = case type
        when :fill
          'scn'
        when :stroke
          'SCN'
        else
          raise ArgumentError, "unknown type '#{type}'"
        end

        set_color_space type, :Pattern
        add_content "/SP#{registry_key} #{operator}"
      end

      def gradient_registry_key(gradient)
        if gradient[1].is_a?(Array) # axial
          [
            map_to_absolute(gradient[0]),
            map_to_absolute(gradient[1]),
            gradient[2], gradient[3]
          ]
        else # radial
          [
            map_to_absolute(gradient[0]),
            gradient[1],
            map_to_absolute(gradient[2]),
            gradient[3],
            gradient[4], gradient[5]
          ]
        end.hash
      end

      def gradient_registry
        @gradient_registry ||= {}
      end

      def gradient(*args)
        if args.length != 4 && args.length != 6
          raise ArgumentError, "Unknown type of gradient: #{args.inspect}"
        end

        color1 = make_color(args[-2])
        color2 = make_color(args[-1])

        if color1.color_space != color2.color_space
          raise ArgumentError, "Both colors must be of the same color space: #{color1.inspect} and #{color2.inspect}"
        end

        shader = ref!({
          :FunctionType => 2,
          :Domain => [0.0, 1.0],
          :C0 => color1.to_pdf,
          :C1 => color2.to_pdf,
          :N => 1.0,
        })

        shading = ref!({
          :ShadingType => args.length == 4 ? 2 : 3, # axial : radial shading
          :ColorSpace => color1.color_space,
          :Coords => args.length == 4 ?
                        [0, 0, args[1].first - args[0].first, args[1].last - args[0].last] :
                        [0, 0, args[1], args[2].first - args[0].first, args[2].last - args[0].last, args[3]],
          :Function => shader,
          :Extend => [true, true],
        })

        ref!({
          :PatternType => 2, # shading pattern
          :Shading => shading,
          :Matrix => [1, 0,
                      0, 1] + map_to_absolute(args[0]),
        })
      end
    end
  end
end
