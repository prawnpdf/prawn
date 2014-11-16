module Prawn
  module Color
    class ColorFactory
      def self.build(*color)
        return color[0] if color[0].is_a? ::Prawn::Color::Color
        case(color.size)
        when 1
          raise ArgumentError, 'Provided color must be a string' unless color[0].class == String
          RGBColor.new(color[0])
        when 4
          CYMKColor.new(color)
        else
          raise ArgumentError, 'wrong number of arguments supplied'
        end
      end
    end
  end
end


