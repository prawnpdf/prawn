# encoding: utf-8

# color.rb : Implements color handling
#
# Copyright June 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Graphics
    module Color
      # @group Stable API

      # Sets or returns the fill color.
      #
      # When called with no argument, it returns the current fill color.
      #
      # If a single argument is provided, it should be a 6 digit HTML color
      # code.
      #
      #   pdf.fill_color "f0ffc1"
      #
      # If 4 arguments are provided, the color is assumed to be a CMYK value
      # Values range from 0 - 100.
      #
      #   pdf.fill_color 0, 99, 95, 0
      #
      def fill_color(*color)
        return current_fill_color if color.empty?
        self.current_fill_color = make_color(*color)
        set_fill_color
      end

      alias_method :fill_color=, :fill_color

      # Sets or returns the line stroking color.
      #
      # When called with no argument, it returns the current stroking color.
      #
      # If a single argument is provided, it should be a 6 digit HTML color
      # code.
      #
      #   pdf.stroke_color "f0ffc1"
      #
      # If 4 arguments are provided, the color is assumed to be a CMYK value
      # Values range from 0 - 100.
      #
      #   pdf.stroke_color 0, 99, 95, 0
      #
      def stroke_color(*color)
        return current_stroke_color if color.empty?
        color = make_color(*color)
        self.current_stroke_color = color
        set_stroke_color(color)
      end

      alias_method :stroke_color=, :stroke_color

      module_function

      # Converts RGB value array to hex string suitable for use with fill_color
      # and stroke_color
      #
      #   >> Prawn::Graphics::Color.rgb2hex([255,120,8])
      #   => "ff7808"
      #
      def rgb2hex(rgb)
        rgb.map { |e| "%02x" % e }.join
      end

      # Converts hex string into RGB value array:
      #
      #  >> Prawn::Graphics::Color.hex2rgb("ff7808")
      #  => [255, 120, 8]
      #
      def hex2rgb(hex)
        r,g,b = hex[0..1], hex[2..3], hex[4..5]
        [r,g,b].map { |e| e.to_i(16) }
      end

      # Convert argument(s) into a PDFColor
      def make_color(*color)
        ###puts "make_color(#{ color.inspect })"
        if color.is_a? Prawn::PDFColor
          color
        else
          case(color.size)
          when 1
            if color[0].is_a? Prawn::PDFColor
              color[0]
            else
              Prawn::CSSColor.new color[0]
            end
          when 4
            Prawn::CSSColor.new color
          else
            raise ArgumentError, 'wrong number of arguments supplied'
          end
        end
      end

      private

      # All PDF 1.3 color spaces.  Should somebody subclass PDFColor to
      # support any of these.
      PDF_COLOR_SPACES = [:DeviceGray, :DeviceRGB, :DeviceCMYK,
                          :CalGray, :CalRGB, :Lab, :ICCBased,
                          :Indexed, :Pattern, :Separation, :DeviceN]

      def set_color_space(type, color_space)
        # don't set the same color space again
        return if current_color_space(type) == color_space && !state.page.in_stamp_stream?
        set_current_color_space(color_space, type)

        unless PDF_COLOR_SPACES.include?(color_space)
          raise ArgumentError, "unknown color space: '#{color_space}'"
        end

        operator = case type
        when :fill
          'cs'
        when :stroke
          'CS'
        else
          raise ArgumentError, "unknown type '#{type}'"
        end

        add_content "#{ PDF::Core::PdfObject(color_space.to_sym) } #{operator}"
      end

      def set_color(type, color, options = {})
        operator = case type
        when :fill
          'scn'
        when :stroke
          'SCN'
        else
          raise ArgumentError, "unknown type '#{type}'"
        end

        unless color.opaque?
          raise ArgumentError, "Can not use transparent or translucent colors: #{color.inspect}"
        end

        set_color_space type, color.color_space
        write_color(color, operator)
      end

      def set_fill_color(color = nil)
        set_color :fill, color || current_fill_color
      end

      def set_stroke_color(color = nil)
        set_color :stroke, color || current_stroke_color
      end

      def update_colors
        set_fill_color
        set_stroke_color
      end

      private

      def current_color_space(type)
        graphic_state.color_space[type]
      end

      def set_current_color_space(color_space, type)
        save_graphics_state if graphic_state.nil?
        graphic_state.color_space[type] = color_space
      end

      def current_fill_color
        graphic_state.fill_color
      end

      def current_fill_color=(color)
        graphic_state.fill_color = color
      end

      def current_stroke_color
        graphic_state.stroke_color
      end

      def current_stroke_color=(color)
        graphic_state.stroke_color = color
      end

      def write_fill_color
        write_color(current_fill_color, 'scn')
      end

      def write_stroke_color
        write_color(current_fill_color, 'SCN')
      end

      def write_color(color, operator)
        add_content "#{color.to_pdf} #{operator}"
      end

    end
  end
end

