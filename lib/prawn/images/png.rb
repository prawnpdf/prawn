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

      # Process a new PNG image
      #
      # <tt>:data</tt>:: A string containing a full PNG file
      def initialize(data)
        data = StringIO.new(data.dup)

        data.read(8)  # Skip the default header

        ok        = true
        @palette  = ""
        @img_data = ""

        while ok
          chunk_size  = data.read(4).unpack("N")[0]
          section     = data.read(4)
          case section
          when 'IHDR'
            # we can grab other interesting values from here (like width,
            # height, etc)
            case data.read(chunk_size).unpack("NNCCCCC")[3]
            when 0
              @color_type = :greyscale
            when 2
              @color_type = :rgb
            when 3
              @color_type = :indexed
            end
          when 'PLTE'
            @palette << data.read(chunk_size)
          when 'IDAT'
            @img_data << data.read(chunk_size)
          when 'tRNS'
            # This chunk can only occur once and it must occur after the
            # PLTE chunk and before the IDAT chunk
            @transparency = {}
            case @color_type
            when :indexed
              # Indexed colour, RGB. Each byte in this chunk is an alpha for
              # the palette index in the PLTE ("palette") chunk up until the
              # last non-opaque entry. Set up an array, stretching over all
              # palette entries which will be 0 (opaque) or 1 (transparent).
              @transparency[:type]  = 'indexed'
              @transparency[:data]  = data.read(chunk_size).unpack("C*")
            when :greyscale
              # Greyscale. Corresponding to entries in the PLTE chunk.
              # Grey is two bytes, range 0 .. (2 ^ bit-depth) - 1
              @transparency[:grayscale] = data.read(2).unpack("n")
              @transparency[:type]      = 'indexed'
            when :rgb
              # True colour with proper alpha channel.
              @transparency[:rgb] = data.read(6).unpack("nnn")
            end
          when 'IEND'
            # we've got everything we need, exit the loop
            ok = false
          else
            # unknown (or un-important) section, skip over it
            data.seek(data.pos + chunk_size)
          end

          data.read(4)  # Skip the CRC
        end
      end
    end
  end
end
