# encoding: ASCII-8BIT

# png.rb : Extracts the data from a PNG that is needed for embedding
#
# Based on some similar code in PDF::Writer by Austin Ziegler
#
# Copyright April 2008, James Healy.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'stringio'

module Prawn
  module Images
    # A convenience class that wraps the logic for extracting the parts
    # of a PNG image that we need to embed them in a PDF
    class PNG 
      attr_reader :palette, :img_data, :transparency
      attr_reader :width, :height, :bits
      attr_reader :color_type, :compression_method, :filter_method
      attr_reader :interlace_method, :alpha_channel
      attr_accessor :scaled_width, :scaled_height
      
      # Process a new PNG image
      #
      # <tt>data</tt>:: A string containing a full PNG file
      #
      def initialize(data)
        data = StringIO.new(data.dup)

        data.read(8)  # Skip the default header

        @palette  = ""
        @img_data = ""
        @transparency = {}

        loop do
          chunk_size  = data.read(4).unpack("N")[0]
          section     = data.read(4)
          case section
          when 'IHDR'
            # we can grab other interesting values from here (like width,
            # height, etc)
            values = data.read(chunk_size).unpack("NNCCCCC")

            @width              = values[0]
            @height             = values[1]
            @bits               = values[2]
            @color_type         = values[3]
            @compression_method = values[4]
            @filter_method      = values[5]
            @interlace_method   = values[6]
          when 'PLTE'
            @palette << data.read(chunk_size)
          when 'IDAT'
            @img_data << data.read(chunk_size)
          when 'tRNS'
            # This chunk can only occur once and it must occur after the
            # PLTE chunk and before the IDAT chunk
            @transparency = {}
            case @color_type
            when 3
              # Indexed colour, RGB. Each byte in this chunk is an alpha for
              # the palette index in the PLTE ("palette") chunk up until the
              # last non-opaque entry. Set up an array, stretching over all
              # palette entries which will be 0 (opaque) or 1 (transparent).
              @transparency[:indexed]  = data.read(chunk_size).unpack("C*")
              short = 255 - @transparency[:indexed].size
              @transparency[:indexed] += ([255] * short) if short > 0
            when 0
              # Greyscale. Corresponding to entries in the PLTE chunk.
              # Grey is two bytes, range 0 .. (2 ^ bit-depth) - 1
              grayval = data.read(chunk_size).unpack("n").first
              @transparency[:grayscale] = grayval
            when 2
              # True colour with proper alpha channel.
              @transparency[:rgb] = data.read(chunk_size).unpack("nnn")
            end
          when 'IEND'
            # we've got everything we need, exit the loop
            break
          else
            # unknown (or un-important) section, skip over it
            data.seek(data.pos + chunk_size)
          end

          data.read(4)  # Skip the CRC
        end

        # if our img_data contains alpha channel data, split it out
        unfilter_image_data if alpha_channel?
      end

      def pixel_bytes
        @pixel_bytes ||= case @color_type
        when 0, 3, 4 then 1
        when 1, 2, 6 then 3
        end
      end

      private

      def alpha_channel?
        @color_type == 4 || @color_type == 6
      end

      def unfilter_image_data
        data = Zlib::Inflate.inflate(@img_data).unpack 'C*'
        @img_data = ""
        @alpha_channel = ""

        # each pixel has the color bytes, plus a byte of alpha channel
        pixel_length = pixel_bytes + 1
        scanline_length = pixel_length * @width + 1 # for filter
        row = 0
        pixels = []    
        paeth, pa, pb, pc = nil
        until data.empty? do
          row_data = data.slice! 0, scanline_length
          filter = row_data.shift
          case filter
          when 0 # None
          when 1 # Sub
            row_data.each_with_index do |byte, index|
              left = index < pixel_length ? 0 : row_data[index - pixel_length]
              row_data[index] = (byte + left) % 256
              #p [byte, left, row_data[index]]
            end
          when 2 # Up
            row_data.each_with_index do |byte, index|
              col = index / pixel_length
              upper = row == 0 ? 0 : pixels[row-1][col][index % pixel_length]
              row_data[index] = (upper + byte) % 256
            end
          when 3  # Average
            row_data.each_with_index do |byte, index|
              col = index / pixel_length
              upper = row == 0 ? 0 : pixels[row-1][col][index % pixel_length]
              left = index < pixel_length ? 0 : row_data[index - pixel_length]

              row_data[index] = (byte + ((left + upper)/2).floor) % 256
            end
          when 4 # Paeth
            left = upper = upper_left = nil
            row_data.each_with_index do |byte, index|
              col = index / pixel_length

              left = index < pixel_length ? 0 : row_data[index - pixel_length]
              if row.zero?
                upper = upper_left = 0
              else
                upper = pixels[row-1][col][index % pixel_length]
                upper_left = col.zero? ? 0 :
                  pixels[row-1][col-1][index % pixel_length]
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
              
              row_data[index] = (byte + paeth) % 256
              #p [byte, paeth, row_data[index]]
            end
          else
            raise ArgumentError, "Invalid filter algorithm #{filter}"
          end

          s = []
          row_data.each_slice pixel_length do |slice|
            s << slice
          end
          pixels << s
          row += 1
        end

        # convert the pixel data to seperate strings for colours and alpha
        pixels.each do |row|
          row.each do |pixel|
            @img_data << pixel[0,pixel_bytes].pack("C*")
            @alpha_channel << pixel.last
          end
        end

        # compress the data
        @img_data = Zlib::Deflate.deflate(@img_data)
        @alpha_channel = Zlib::Deflate.deflate(@alpha_channel)
      end
    end
  end
end
