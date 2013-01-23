# encoding: utf-8

# patterns.rb : Shading patterns (a.k.a. gradients)
#
# Originally implemented by Wojciech Piekutowski. November, 2009
# Copyright September 2012, Alexander Mankuta. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Graphics

    ##
    # This module implements Shading patterns.
    #
    # Both fill_gradient and stroke_gradient accept absolutely identical sets of
    # arguments. The only difference, obviously, is that one sets fill shading
    # and the other sets stroke shading.
    #
    # == Basic gradients
    #
    # Linear and radial gradients are one of the simplest shadings supported by
    # PDF.
    #
    # === Linear gradient
    #
    #   fill_gradient(from, to, color1, color2)
    #
    # from::
    #     This is the starting point of the gradient. It must be an arrays of
    #     two values: <tt>[x, y]</tt>.
    #
    # to::
    #     This is the ending point of the gradient. Format is the same:
    #     <tt>[x, y]</tt>.
    #
    # color1::
    #     Color of the gradient at the starting point.
    #
    # color2::
    #     Color of the gradient at the ending point of the gradient.
    #
    # Please note that both colors must be in the same color space.
    #
    # === Radial gradient
    #
    #   fill_gradient(from, r1, to, r2, color1, color2)
    #
    # from::
    #     This is the starting point of the gradient. It must be an arrays of
    #     two values: <tt>[x, y]</tt>.
    #
    # r1::
    #     Radius of the starting circle.
    #
    # to::
    #     This is the ending point of the gradient. Format is the same:
    #     <tt>[x, y]</tt>.
    #
    # r2::
    #     Radius of the ending circle.
    #
    # color1::
    #     Color of the gradient at the starting point.
    #
    # color2::
    #     Color of the gradient at the ending point of the gradient.
    #
    # Please note that both colors must be in the same color space.
    #
    #
    # == More complex gradients
    #
    # PDF is capable of creating very complex shadings. Though, this
    # functionality is rarely used.
    #
    # Because this gradients require variable amounts of data to be properly
    # constructed gradient methods are called with a single parameter stating
    # the type of gradient you want to produce and a block that returns actual
    # data for gradient.
    #
    # [Note]
    #   This types of shading are not supported by all renderers.
    #   For example PDF.js doesn't support any of this shadings. OS X Preview
    #   (10.8) has problems with flags other than 0 and renders Tensor-Product
    #   Patch Meshes exactly the same as Coons Patch Meshes.
    #
    # === Free-Form Gouraud-Shaded Triangle Meshes
    #
    #   fill_gradient(:ffgstm) {
    #     [
    #       # vertices
    #     ]
    #   }
    #
    # The data is an Array of vertices. Each vertex has the following format:
    # <tt>[flag, x, y, color]</tt>.
    #
    # Colors of all vertices must be in the same color space.
    #
    # Please refer to <b>PDF Refernce, Section 4.6.3, Shading Types, Type
    # 4 Shadings</b> for more details on the meaning of the vertex fields.
    #
    #
    # === Lattice-Form Gouraud-Shaded Triangle Meshes
    #
    #   fill_gradient(:lfgstm) {
    #     [
    #       # data
    #     ]
    #   }
    #
    # The data is a rectangular matrix of vertices. That is an array of rows (arrays)
    # of vertices. It must have at least 2 rows and at least 2 column. Each vertex has
    # the following format: <tt>[x, y, color]</tt>.
    #
    # Colors of all vertices must be in the same color space.
    #
    # Please refer to <b>PDF Refernce, Section 4.6.3, Shading Types, Type
    # 5 Shadings</b> for more details on the meaning of the vertex fields.
    #
    #
    # === Coons Patch Meshes
    #
    #   fill_gradient(:cpm) {
    #     [
    #       # data
    #     ]
    #   }
    #
    # The data is an array of patches. There are two types of patches. They're
    # distinguished by their flag parameter.
    #
    # First one is a stand alone patches. Their flag = 0. They have a form of <tt>[0 (flag),
    # x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6, x7, y7, x8, y8, x9, y9, x10, y10,
    # x11, y11, x12, y12, c1, c2, c3, c4]</tt>.
    #
    # The second is a edge-sharing patches. Their flag is either 1, 2, or 3. And
    # they have 4 less points (because they borrow them from previous patch) and
    # 2 less colors. They have a form of <tt>[flag, x5, y5, x6, y6, x7, y7, x8, y8, x9, y9,
    # x10, y10, x11, y11, x12, y12, c3, c4]</tt>.
    #
    # Please refer to <b>PDF Refernce, Section 4.6.3, Shading Types, Type
    # 6 Shadings</b> for more details on the meaning of the patch fields.
    #
    # === Tensor-Product Patch Meshes
    #
    #   fill_gradient(:tppm) {
    #     [
    #       # data
    #     ]
    #   }
    #
    # This type of shading is very similar to Coons Patch Mesh except it has
    # 4 extra pairs of coordinates in every patch, right before the colors.
    #
    # Please refer to <b>PDF Refernce, Section 4.6.3, Shading Types, Type
    # 7 Shadings</b> for more details on the meaning of the patch fields.
    #
    module Patterns

      ##
      # :call-seq:
      #   fill_gradient(from, to, color1, color2)
      #   fill_gradient(from, r1, to, r2, color1, color2)
      #   fill_gradient(complex_shading_type) { }
      #
      # Sets the fill gradient.
      def fill_gradient(*args, &block)
        if args[1].is_a?(Array) || args[2].is_a?(Array) || args[0].is_a?(Symbol)
          set_gradient(:fill, *args, &block)
        else
          warn "[DEPRECATION] 'fill_gradient(point, width, height,...)' is deprecated in favor of 'fill_gradient(from, to,...)'. " +
               "Old arguments will be removed in release 1.1"
          set_gradient :fill, args[0], [args[0].first, args[0].last - args[2]], args[3], args[4]
        end
      end

      ##
      # :call-seq:
      #   stroke_gradient(from, to, color1, color2)
      #   stroke_gradient(from, r1, to, r2, color1, color2)
      #   stroke_gradient(complex_shading_type) { }
      #
      # Sets the stroke gradient.
      def stroke_gradient(*args, &block)
        if args[1].is_a?(Array) || args[2].is_a?(Array) ||  args[0].is_a?(Symbol)
          set_gradient(:stroke, *args, &block)
        else
          warn "[DEPRECATION] 'stroke_gradient(point, width, height,...)' is deprecated in favor of 'stroke_gradient(from, to,...)'. " +
               "Old arguments will be removed in release 1.1"
          set_gradient :stroke, args[0], [args[0].first, args[0].last - args[2]], args[3], args[4]
        end
      end

      private

      def set_gradient(type, *grad, &block)
        patterns = page.resources[:Pattern] ||= {}

        registry_key = gradient_registry_key grad, &block

        if patterns["SP#{registry_key}"]
          shading = patterns["SP#{registry_key}"]
        else
          unless shading = gradient_registry[registry_key]
            shading = gradient(*grad, &block)
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
        if gradient[0].is_a?(Symbol) # all kinds of patches
          [
            gradient[0],
            *yield
          ]
        elsif gradient[1].is_a?(Array) # axial
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

      def gradient(*args, &block)
        if args.length != 1 && args.length != 4 && args.length != 6
          raise ArgumentError, "Unknown type of gradient: #{args.inspect}"
        end

        case args.length
        when 1
          case args.first
          when :ffgstm  # Free-Form Gouraud-Shaded Triangle Meshes
            shading_type_4(&block)
          when :lfgstm  # Lattice-Form Gouraud-Shaded Triangle Meshes
            shading_type_5(&block)
          when :cpm  # Coons Patch Meshes
            shading_type_6(&block)
          when :tppm  # Tensor-Product Patch Meshes
            shading_type_7(&block)
          else
            raise ArgumentError, "Unknown type of gradient: #{args.inspect}"
          end
        when 4
          shading_type_2(*args)
        when 6
          shading_type_3(*args)
        else
          raise ArgumentError, "Unknown type of gradient: #{args.inspect}"
        end
      end

      def shading_type_2(from, to, from_color, to_color)
        color1 = normalize_color(from_color).dup.freeze
        color2 = normalize_color(to_color).dup.freeze

        if color_type(color1) != color_type(color2)
          raise ArgumentError, "Both colors must be of the same color space: #{color1.inspect} and #{color2.inspect}"
        end

        process_color color1
        process_color color2

        shader = ref!({
          :FunctionType => 2,
          :Domain => [0.0, 1.0],
          :C0 => color1,
          :C1 => color2,
          :N => 1.0,
        })

        shading = ref!({
          :ShadingType => 2, # axial shading
          :ColorSpace => color_space(color1),
          :Coords => [0, 0, to.first - from.first, to.last - from.last],
          :Function => shader,
          :Extend => [true, true],
        })

        ref!({
          :PatternType => 2, # shading pattern
          :Shading => shading,
          :Matrix => [1, 0, 0, 1] + map_to_absolute(from),
        })
      end

      def shading_type_3(from, r1, to, r2, from_color, to_color)
        color1 = normalize_color(from_color).dup.freeze
        color2 = normalize_color(to_color).dup.freeze

        if color_type(color1) != color_type(color2)
          raise ArgumentError, "Both colors must be of the same color space: #{color1.inspect} and #{color2.inspect}"
        end

        process_color color1
        process_color color2

        shader = ref!({
          :FunctionType => 2,
          :Domain => [0.0, 1.0],
          :C0 => color1,
          :C1 => color2,
          :N => 1.0,
        })

        shading = ref!({
          :ShadingType => 3, # radial shading
          :ColorSpace => color_space(color1),
          :Coords => [0, 0, r1, to.first - from.first, to.last - from.last, r2],
          :Function => shader,
          :Extend => [true, true],
        })

        ref!({
          :PatternType => 2, # shading pattern
          :Shading => shading,
          :Matrix => [1, 0, 0, 1] + map_to_absolute(from),
        })
      end

      def shading_type_4
        data = yield

        x_min = x_max = data[0][1]
        y_min = y_max = data[0][2]
        data_color_space = color_space(data[0][3])

        data.each do |(_, x, y, c, extra)|
          x_min = x if x_min > x
          x_max = x if x_max < x
          y_min = y if y_min > y
          y_max = y if y_max < y
          if color_space(c) != data_color_space
            raise ArgumentError, "Colors of all vertices must be in the same color space. Expected #{data_color_space} got #{color_space(c)}"
          end
          if extra
            raise ArgumentError, "Unexpected extra data in vertices stream: #{extra.inspect}"
          end
        end
        x_min = x_min.to_f
        x_max = x_max.to_f
        y_min = y_min.to_f
        y_max = y_max.to_f
        dx = x_max - x_min
        dy = y_max - y_min


        shading = ref!({
          :ShadingType => 4, # Free-Form Gouraud-Shaded Triangle Meshes
          :ColorSpace => data_color_space,
          :BitsPerCoordinate => 32,
          :BitsPerComponent => 8,
          :BitsPerFlag => 8,
          :Decode => [x_min, x_max, y_min, y_max, 0, 1, 0, 1, 0, 1]
        })

        data.each do |(f, x, y, color)|
          unless [0, 1, 2].include? f
            raise ArgumentError, "Flag must be 0, 1, or 2. Got #{f}."
          end

          shading << [
            f,
            normalize_coord(x, x_min, dx), normalize_coord(y, y_min, dy),
            *(normalize_color(color).map{|c| (c * 255.0).round })
          ].pack('CNNC*')
        end


        ref!({
          :PatternType => 2, # shading pattern
          :Shading => shading,
          :Matrix => [1, 0,
                      0, 1] + map_to_absolute([0, 0]),
        })
      end

      def shading_type_5
        data = yield

        x_min = x_max = data[0][0][0]
        y_min = y_max = data[0][0][1]
        data_color_space = color_space(data[0][0][2])

        if data.length < 2
          raise ArgumentError, "Lattice-Form Gouraud-Shaded Triangle Meshes Shading requires at least 2 rows of vertices"
        end

        vertices_per_row = data[0].length
        if vertices_per_row < 2
          raise ArgumentError, "Lattice-Form Gouraud-Shaded Triangle Meshes Shading requires at least 2 vertices per row"
        end

        data.each do |row|
          if vertices_per_row != row.length
            raise ArgumentError, "Lattice-Form Gouraud-Shaded Triangle Meshes Shading requires data to be organized in rectangular matrix"
          end

          row.each do |(x, y, c)|
            x_min = x if x_min > x
            x_max = x if x_max < x
            y_min = y if y_min > y
            y_max = y if y_max < y

            if color_space(c) != data_color_space
              raise ArgumentError, "Colors of all vertices must be in the same color space. Expected #{data_color_space} got #{color_space(c)}"
            end
          end
        end
        x_min = x_min.to_f
        x_max = x_max.to_f
        y_min = y_min.to_f
        y_max = y_max.to_f
        dx = x_max - x_min
        dy = y_max - y_min


        shading = ref!({
          :ShadingType => 5, # Lattice-Form Gouraud-Shaded Triangle Meshes
          :ColorSpace => :DeviceRGB,
          :BitsPerCoordinate => 32,
          :BitsPerComponent => 8,
          :VerticesPerRow => data[0].length,
          :Decode => [x_min, x_max, y_min, y_max, 0, 1, 0, 1, 0, 1]
        })


        data.each do |row|
          row.each do |(x, y, color)|
            shading << [
              normalize_coord(x, x_min, dx), normalize_coord(y, y_min, dy),
              *(normalize_color(color).map{|c| (c * 255.0).round })
            ].pack('NNC*')
          end
        end


        ref!({
          :PatternType => 2, # shading pattern
          :Shading => shading,
          :Matrix => [1, 0,
                      0, 1] + map_to_absolute([0, 0]),
        })
      end

      def shading_type_6
        data = yield

        x_min = x_max = data[0][1]
        y_min = y_max = data[0][2]
        data_color_space = color_space(data[0][25])

        data.each do |values|
          f = values[0]
          coords = if f == 0
                     values[1..24]
                   else
                     values[1..16]
                   end
          coords.each_with_index do |c, i|
            if i.even? # x coordinate
              x_min = c if x_min > c
              x_max = c if x_max < c
            else # y coordinate
              y_min = c if y_min > c
              y_max = c if y_max < c
            end
          end
        end
        x_min = x_min.to_f
        x_max = x_max.to_f
        y_min = y_min.to_f
        y_max = y_max.to_f
        dx = x_max - x_min
        dy = y_max - y_min


        shading = ref!({
          :ShadingType => 6, # Coons Patch Meshes
          :ColorSpace => data_color_space,
          :BitsPerCoordinate => 32,
          :BitsPerComponent => 8,
          :BitsPerFlag => 8,
          :Decode => [x_min, x_max, y_min, y_max, 0, 1, 0, 1, 0, 1]
        })


        data.each do |values|
          f = values.shift
          unless [0, 1, 2, 3].include? f
            raise ArgumentError, "Flag must be 0, 1, 2, or 3. Got #{f}."
          end

          if f == 0
            coords = values.shift(24)
            colors = values.shift(4)
          else
            coords = values.shift(16)
            colors = values.shift(2)
          end

          shading << [f].pack('C')

          coords.each_with_index do |c, i|
            if i.even? # x coordinate
              shading << [normalize_coord(c, x_min, dx)].pack('N')
            else
              shading << [normalize_coord(c, y_min, dy)].pack('N')
            end
          end

          colors.each do |color|
            if color_space(color) != data_color_space
              raise ArgumentError, "Colors of all vertices must be in the same color space. Expected #{data_color_space} got #{color_space(color)}"
            end
            shading << normalize_color(color).map{|c| (c * 255.0).round }.pack('C*')
          end
        end


        ref!({
          :PatternType => 2, # shading pattern
          :Shading => shading,
          :Matrix => [1, 0,
                      0, 1] + map_to_absolute([0, 0]),
        })
      end

      def shading_type_7
        data = yield

        x_min = x_max = data[0][1]
        y_min = y_max = data[0][2]
        data_color_space = color_space(data[0][33])

        data.each do |values|
          f = values[0]
          coords = if f == 0
                     values[1..32]
                   else
                     values[1..24]
                   end
          coords.each_with_index do |c, i|
            if i.even? # x coordinate
              x_min = c if x_min > c
              x_max = c if x_max < c
            else # y coordinate
              y_min = c if y_min > c
              y_max = c if y_max < c
            end
          end
        end
        x_min = x_min.to_f
        x_max = x_max.to_f
        y_min = y_min.to_f
        y_max = y_max.to_f
        dx = x_max - x_min
        dy = y_max - y_min


        shading = ref!({
          :ShadingType => 7, # Tensor-Product Patch Meshes
          :ColorSpace => data_color_space,
          :BitsPerCoordinate => 32,
          :BitsPerComponent => 8,
          :BitsPerFlag => 8,
          :Decode => [x_min, x_max, y_min, y_max, 0, 1, 0, 1, 0, 1]
        })


        data.each do |values|
          f = values.shift
          unless [0, 1, 2, 3].include? f
            raise ArgumentError, "Flag must be 0, 1, 2, or 3. Got #{f}."
          end

          if f == 0
            coords = values.shift(32)
            colors = values.shift(4)
          else
            coords = values.shift(24)
            colors = values.shift(2)
          end

          shading << [f].pack('C')

          coords.each_with_index do |c, i|
            if i.even? # x coordinate
              shading << [normalize_coord(c, x_min, dx)].pack('N')
            else
              shading << [normalize_coord(c, y_min, dy)].pack('N')
            end
          end

          colors.each do |color|
            if color_space(color) != data_color_space
              raise ArgumentError, "Colors of all vertices must be in the same color space. Expected #{data_color_space} got #{color_space(color)}"
            end
            shading << normalize_color(color).map{|c| (c * 255.0).round }.pack('C*')
          end
        end


        ref!({
          :PatternType => 2, # shading pattern
          :Shading => shading,
          :Matrix => [1, 0,
                      0, 1] + map_to_absolute([0, 0]),
        })
      end

      def normalize_coord(coord, min, delta)
        diff = (coord.to_f - min) / delta
        if diff > 1
          diff = 1.0
        elsif diff < 0
          diff = 0.0;
        end

        (diff * 0xffffffff).round
      end
    end
  end
end
