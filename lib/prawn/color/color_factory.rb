module Prawn
  module Color
    class ColorFactory
      def self.build(*color)
        case(color.size)
        when 1
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


