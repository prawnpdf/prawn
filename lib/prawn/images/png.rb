require 'stringio'

module Prawn
  module Images
    class PNG
      attr_accessor :palette, :img_data, :transparency

      def initialize(data, color_type)
        data = StringIO.new(data.dup)

        data.read(8)  # Skip the default header

        ok        = true
        length    = data.size
        @palette  = ""
        @img_data = ""

        while ok
          chunk_size  = data.read(4).unpack("N")[0]
          section     = data.read(4)
          case section
          when 'PLTE'
            palette << data.read(chunk_size)
          when 'IDAT'
            @img_data << data.read(chunk_size)
          when 'tRNS'
            # This chunk can only occur once and it must occur after the
            # PLTE chunk and before the IDAT chunk
            @transparency = {}
            case color_type
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
          else
            data.seek(data.pos + chunk_size)
          end

          ok = (section != "IEND")

          data.read(4)  # Skip the CRC
        end
      end
    end
  end
end
