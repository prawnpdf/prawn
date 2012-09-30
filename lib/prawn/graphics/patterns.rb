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
      class Gradient
        include Prawn::Graphics
        include Prawn::Graphics::Color

        private

        def initialize
        end

        def map_to_absolute(*point)
          @doc.send :map_to_absolute, *point
        end
      end

      class LinearGradient < Gradient
        def initialize(doc, from, to, color1, color2)
          @doc = doc
          @from = from.dup.freeze
          @to = to.dup.freeze
          @color1 = normalize_color(color1).dup.freeze
          @color2 = normalize_color(color2).dup.freeze

          if color_type(@color1) != color_type(@color2)
            raise ArgumentError, "Both colors must be of the same color space: #{@color1.inspect} and #{@color2.inspect}"
          end

          process_color @color1
          process_color @color2

          shader = @doc.ref!({
            :FunctionType => 2,
            :Domain => [0.0, 1.0],
            :C0 => @color1,
            :C1 => @color2,
            :N => 1.0,
          })

          shading = @doc.ref!({
            :ShadingType => 2, # axial shading
            :ColorSpace => color_space(@color1),
            :Coords => [0, 0] + [@to.first - @from.first, @to.last - @from.last],
            :Function => shader,
            :Extend => [true, true],
          })

          shading_pattern = @doc.ref!({
            :PatternType => 2, # shading pattern
            :Shading => shading,
            :Matrix => [1, 0,
                        0, 1] + map_to_absolute(@from),
          })

          patterns = @doc.page.resources[:Pattern] ||= {}
          @id = patterns.empty? ? 'SP1' : patterns.keys.sort.last.succ
          patterns[id] = shading_pattern
        end

        attr_reader :from, :to, :color1, :color2, :id

        def dup
          self.class.new @doc, @from, @to, @color1, @color2
        end
      end

      class RadialGradient < Gradient
        def initialize(doc, from, r1, to, r2, color1, color2)
          @doc = doc
          @from = from.dup.freeze
          @r1 = r1
          @to = to.dup.freeze
          @r2 = r2
          @color1 = normalize_color(color1).dup.freeze
          @color2 = normalize_color(color2).dup.freeze

          if color_type(color1) != color_type(color2)
            raise ArgumentError, "Both colors must be of the same color space: #{@color1.inspect} and #{@color2.inspect}"
          end

          process_color @color1
          process_color @color2

          shader = @doc.ref!({
            :FunctionType => 2,
            :Domain => [0.0, 1.0],
            :C0 => @color1,
            :C1 => @color2,
            :N => 1.0,
          })

          shading = @doc.ref!({
            :ShadingType => 3, # radial shading
            :ColorSpace => color_space(@color1),
            #:Coords => map_to_absolute(from) + [r1] + map_to_absolute(to) + [r2],
            :Coords => [0, 0, @r1, @to.first - @from.first, @to.last - @from.last, @r2],
            :Function => shader,
            #:Extend => [true, true],
          })

          shading_pattern = @doc.ref!({
            :PatternType => 2, # shading pattern
            :Shading => shading,
            :Matrix => [1, 0,
                        0, 1] + map_to_absolute(@from),
          })

          patterns = @doc.page.resources[:Pattern] ||= {}
          @id = patterns.empty? ? 'SP1' : patterns.keys.sort.last.succ
          patterns[@id] = shading_pattern
        end

        attr_reader :from, :r1, :to, :r2, :color1, :color2, :id

        def dup
          self.class.new @doc, @from, @r1, @to, @r2, @color1, @color2
        end
      end

      # Creates linear gradient from color1 to color2.
      #
      # It accepts CMYK and RGB colors, like #fill_color. Both colors must be
      # of the same type.
      #
      # from and to are refernce points of gradient start and end respectively.
      # For example, if you want to have page full of text
      # with gradually changing color:
      #
      # g = pdf.linear_gradient [0, pdf.bounds.height], [pdf.bounds.width,
      # pdf.bounds.height], 'FF0000', '0000FF'
      # pdf.text 'lots of text'*1000
      def linear_gradient(from, to, color1, color2)
        LinearGradient.new(self, from, to, color1, color2)
      end

      # Creates radial gradient from color1 to color2.
      #
      # It accepts CMYK and RGB colors, like #fill_color. Both colors must be
      # of the same type.
      #
      # from and to are refernce points of gradient start and end respectively.
      # r1 and r2 are radiuses of the gradient circles at the start and end
      # respectively.
      def radial_gradient(from, r1, to, r2, color1, color2)
        RadialGradient.new(self, from, r1, to, r2, color1, color2)
      end

      def set_gradient(type, gradient)
        patterns = page.resources[:Pattern] ||= {}
        unless patterns[gradient.id]
          gradient = gradient.dup
        end

        set_color type, gradient.id, :pattern => true
        gradient
      end


      def fill_gradient(point, width, height, color1, color2, options = {})
        warn "[DEPRECATION] 'fill_gradient' is deprecated in favor of 'set_gradient :fill, linear_gradient(...)'. " +
             "'fill_gradient' will be removed in release 1.1"
        set_gradient :fill, point, [point.first, point.last - height], color1, color2
      end

      def stroke_gradient(point, width, height, color1, color2, options = {})
        warn "[DEPRECATION] 'stroke_gradient' is deprecated in favor of 'set_gradient :stroke, linear_gradient(...)'. " +
             "'stroke_gradient' will be removed in release 1.1"
        set_gradient :stroke, point, [point.first, point.last - height], color1, color2
      end
    end
  end
end
