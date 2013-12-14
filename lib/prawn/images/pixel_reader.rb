module Prawn
  module Images
    class PixelReader
      attr_reader :pixels

      def initialize(data, pixel_bytes, scanline_length)
        @pixels = []

        row = 0
        row_data = [] # reused for each row of the image
        paeth, pa, pb, pc = nil

        data.bytes.each do |byte|
          # accumulate a whole scanline of bytes, and then process it all at once
          # we could do this with Enumerable#each_slice, but it allocates memory,
          #   and we are trying to avoid that
          row_data << byte
          next if row_data.length < scanline_length

          filter = row_data.shift
          case filter
          when 0 # None
          when 1 # Sub
            row_data.each_with_index do |row_byte, index|
              left = index < pixel_bytes ? 0 : row_data[index - pixel_bytes]
              row_data[index] = (row_byte + left) % 256
            end
          when 2 # Up
            row_data.each_with_index do |row_byte, index|
              col = (index / pixel_bytes).floor
              upper = row == 0 ? 0 : @pixels[row-1][col][index % pixel_bytes]
              row_data[index] = (upper + row_byte) % 256
            end
          when 3  # Average
            row_data.each_with_index do |row_byte, index|
              col = (index / pixel_bytes).floor
              upper = row == 0 ? 0 : @pixels[row-1][col][index % pixel_bytes]
              left = index < pixel_bytes ? 0 : row_data[index - pixel_bytes]

              row_data[index] = (row_byte + ((left + upper)/2).floor) % 256
            end
          when 4 # Paeth
            left = upper = upper_left = nil
            row_data.each_with_index do |row_byte, index|
              col = (index / pixel_bytes).floor

              left = index < pixel_bytes ? 0 : row_data[index - pixel_bytes]
              if row.zero?
                upper = upper_left = 0
              else
                upper = @pixels[row-1][col][index % pixel_bytes]
                upper_left = col.zero? ? 0 :
                  @pixels[row-1][col-1][index % pixel_bytes]
              end

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
          else
            raise ArgumentError, "Invalid filter algorithm #{filter}"
          end

          s = []
          row_data.each_slice pixel_bytes do |slice|
            s << slice
          end
          @pixels << s
          row += 1
          row_data.clear
        end
      end
    end
  end
end
