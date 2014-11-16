# encoding: utf-8
module Prawn
  module Color
    class Color
      def normalize_color(color)
        raise NotImplementedError
      end

      def color_space
        raise NotImplementedError
      end

      def color_to_s
        normalize_color.map { |c| '%.3f' % c }.join(' ')
      end

      def base_representation
        @color
      end
    end
  end
end

