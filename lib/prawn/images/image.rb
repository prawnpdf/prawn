# frozen_string_literal: true

require 'digest/sha1'

module Prawn
  module Images
    # Base class for image info objects
    # @abstract
    class Image
      # @group Extension API

      # Calculate the final image dimensions from provided options.
      # @private
      def calc_image_dimensions(options)
        w = options[:width] || width
        h = options[:height] || height

        if options[:width] && !options[:height]
          wp = w / Float(width)
          w = width * wp
          h = height * wp
        elsif options[:height] && !options[:width]
          hp = h / Float(height)
          w = width * hp
          h = height * hp
        elsif options[:scale]
          w = width * options[:scale]
          h = height * options[:scale]
        elsif options[:fit]
          bw, bh = options[:fit]
          bp = bw / Float(bh)
          ip = width / Float(height)
          if ip > bp
            w = bw
            h = bw / ip
          else
            h = bh
            w = bh * ip
          end
        end
        self.scaled_width = w
        self.scaled_height = h

        [w, h]
      end
    end
  end
end
