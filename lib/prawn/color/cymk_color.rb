module Prawn
  module Color
    class CYMKColor < Color
      def initialize(color)
        @color = color
      end

      def normalize_color
        c,m,y,k = @color
        [c / 100.0, m / 100.0, y / 100.0, k / 100.0]
      end

      def color_space
        :DeviceCMYK
      end
    end
  end
end
