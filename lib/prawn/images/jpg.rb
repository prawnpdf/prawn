# encoding: ASCII-8BIT

# jpg.rb : Extracts the data from a JPG that is needed for embedding
#
# Copyright April 2008, James Healy.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'stringio'

module Prawn
  module Images
    # A convenience class that wraps the logic for extracting the parts
    # of a JPG image that we need to embed them in a PDF
    #
    class JPG 
      attr_reader :width, :height, :bits, :channels
      attr_accessor :scaled_width, :scaled_height
      
      JPEG_SOF_BLOCKS = %W(\xc0 \xc1 \xc2 \xc3 \xc5 \xc6 \xc7 \xc9 \xca \xcb \xcd \xce \xcf)
      JPEG_APP_BLOCKS = %W(\xe0 \xe1 \xe2 \xe3 \xe4 \xe5 \xe6 \xe7 \xe8 \xe9 \xea \xeb \xec \xed \xee \xef)

      # Process a new JPG image
      #
      # <tt>:data</tt>:: A binary string of JPEG data
      #
      def initialize(data)
        data = StringIO.new(data.dup)

        c_marker = "\xff" # Section marker.
        data.read(2)   # Skip the first two bytes of JPEG identifier.
        loop do
          marker, code, length = data.read(4).unpack('aan')
          raise "JPEG marker not found!" if marker != c_marker

          if JPEG_SOF_BLOCKS.include?(code)
            @bits, @height, @width, @channels = data.read(6).unpack("CnnC")
            break
          end

          buffer = data.read(length - 2)
        end
      end
    end
  end
end
