module Prawn
  module Images
    class PixelReader
      FILTERS = { 0 => :filter_none, 
                  1 => :filter_sub, 
                  2 => :filter_up, 
                  3 => :filter_average, 
                  4 => :filter_paeth }

      def initialize(data, pixel_bytes, scanline_length, color_size, alpha_size)
        @pixel_bytes = pixel_bytes
        @color_size = color_size
        @alpha_size = alpha_size

        @rgb_data   = []
        @alpha_data = []

        @previous_row_data = [0]*scanline_length

        data.bytes.each_slice(scanline_length) do |row_data|
          filter = row_data.shift

          if FILTERS.key?(filter)
            send(FILTERS[filter], row_data)
          else
            raise ArgumentError, "Invalid filter algorithm #{filter}"
          end

          @previous_row_data.clear

          row_data.each_with_index do |byte, index|
            pos = index % @pixel_bytes

            if pos < @color_size
              @rgb_data << byte 
            elsif pos < @color_size + @alpha_size
              @alpha_data << byte
            end
          end

          @previous_row_data = row_data
        end
      end

      def rgb_string
        @rgb_data.pack("C*")
      end

      def alpha_string
        @alpha_data.pack("C*")
      end

      def filter_none(row_data)
        # do nothing
      end

      def filter_sub(row_data)
        row_data.each_with_index do |row_byte, index|
          left = index < @pixel_bytes ? 0 : row_data[index - @pixel_bytes]
          row_data[index] = (row_byte + left) % 256
        end
      end

      def filter_up(row_data)
        row_data.each_with_index do |row_byte, index|
          col = (index / @pixel_bytes).floor
          upper = @previous_row_data[col*@pixel_bytes + index % @pixel_bytes]
          row_data[index] = (upper + row_byte) % 256
        end
      end

      def filter_average(row_data)
        row_data.each_with_index do |row_byte, index|
          col = (index / @pixel_bytes).floor
          upper = @previous_row_data[col*@pixel_bytes + index % @pixel_bytes]
          left = index < @pixel_bytes ? 0 : row_data[index - @pixel_bytes]

          row_data[index] = (row_byte + ((left + upper)/2).floor) % 256
        end
      end

      def filter_paeth(row_data)
        left = upper = upper_left = nil
        row_data.each_with_index do |row_byte, index|
          col = (index / @pixel_bytes).floor

          left = index < @pixel_bytes ? 0 : row_data[index - @pixel_bytes]
 
          upper = @previous_row_data[col*@pixel_bytes + index % @pixel_bytes]
          upper_left = col.zero? ? 0 :
            @previous_row_data[(col-1)*@pixel_bytes + index % @pixel_bytes]

          p = left + upper - upper_left
          pa = (p - left).abs
          pb = (p - upper).abs
          pc = (p - upper_left).abs

          paeth = if pa <= pb && pa <= pc
            left
          elsif pb <= pc
            upper
          else
            upper_left
          end

          row_data[index] = (row_byte + paeth) % 256
        end
      end
    end
  end
end
