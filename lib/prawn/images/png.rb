# encoding: utf-8

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
    class PNG #nodoc
      attr_reader :palette, :img_data, :transparency
      attr_reader :width, :height, :bits
      attr_reader :color_type, :compression_method, :filter_method
      attr_reader :interlace_method, :alpha_channel

      # Process a new PNG image
      #
      # <tt>:data</tt>:: A string containing a full PNG file
      def initialize(data)
        data = StringIO.new(data.dup)

        data.read(8)  # Skip the default header

        @palette  = ""
        @img_data = ""

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
              @transparency[:type]  = 'indexed'
              @transparency[:data]  = data.read(chunk_size).unpack("C*")
            when 0
              # Greyscale. Corresponding to entries in the PLTE chunk.
              # Grey is two bytes, range 0 .. (2 ^ bit-depth) - 1
              @transparency[:grayscale] = data.read(2).unpack("n")
              @transparency[:type]      = 'indexed'
            when 2
              # True colour with proper alpha channel.
              @transparency[:rgb] = data.read(6).unpack("nnn")
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
        unfilter_image_data if @color_type == 6
      end

      private

      def paeth(a, b, c) # left, above, upper left
        p = a + b - c
        pa = (p - a).abs
        pb = (p - b).abs
        pc = (p - c).abs

        return a if pa <= pb && pa <= pc
        return b if pb <= pc
        c
      end

      def unfilter_image_data
        data = Zlib::Inflate.inflate(@img_data).unpack 'C*'
        @img_data = ""
        @alpha_channel = ""
        scanline_length = 4 * @width + 1 # for filter
        row = 0
        pixels = []
        until data.empty? do
          row_data = data.slice! 0, scanline_length
          filter = row_data.shift
          case filter
          when 0 then # None
          when 1 then # Sub
            row_data.each_with_index do |byte, index|
              left = index < 4 ? 0 : row_data[index - 4]
              row_data[index] = (byte + left) % 256
              #p [byte, left, row_data[index]]
            end
          when 2 then # Up
            row_data.each_with_index do |byte, index|
              col = index / 4
              upper = row == 0 ? 0 : pixels[row-1][col][index % 4]
              row_data[index] = (upper + byte) % 256
            end
          when 3 then # Average
            row_data.each_with_index do |byte, index|
              col = index / 4
              upper = row == 0 ? 0 : pixels[row-1][col][index % 4]
              left = index < 4 ? 0 : row_data[index - 4]

              row_data[index] = (byte + ((left + upper)/2).floor) % 256
            end
          when 4 then # Paeth
            left = upper = upper_left = nil
            row_data.each_with_index do |byte, index|
              col = index / 4

              left = index < 4 ? 0 : row_data[index - 4]
              if row == 0 then
                upper = upper_left = 0
              else
                upper = pixels[row-1][col][index % 4]
                upper_left = col == 0 ? 0 :
                  pixels[row-1][col-1][index % 4]
              end

              paeth = paeth left, upper, upper_left
              row_data[index] = (byte + paeth) % 256
              #p [byte, paeth, row_data[index]]
            end
          else
            raise ArgumentError, "Invalid filter algorithm #{filter}"
          end

          pixels << []
          row_data.each_slice 4 do |slice|
            pixels.last << slice
          end
          row += 1
        end

        # convert the pixel data to seperate strings for colours and alpha
        pixels.each do |row|
          row.each do |pixel|
            @img_data << pixel[0,3].pack("C*")
            @alpha_channel << pixel[3]
          end
        end

        # compress the data
        @img_data = Zlib::Deflate.deflate(@img_data)
        @alpha_channel = Zlib::Deflate.deflate(@alpha_channel)
      end
    end
  end
end
