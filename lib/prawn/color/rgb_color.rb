module Prawn
  module Color
    class RGBColor < Color
      def initialize(color)
        @color = color
      end

      def to_rgb
        hex2rgb
      end

      def normalize_color
        r,g,b = hex2rgb
        [r / 255.0, g / 255.0, b / 255.0]
      end

      def hex2rgb
        r,g,b = @color[0..1], @color[2..3], @color[4..5]
        [r,g,b].map { |e| e.to_i(16) }
      end

      def color_space
        :DeviceRGB
      end
    end
  end
end
