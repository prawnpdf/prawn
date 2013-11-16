# encoding: utf-8
# image.rb : Base class for image info objects
#
# Copyright September 2011, Brad Ediger. All rights reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'digest/sha1'

module Prawn
  module Images
    class Image

      def calc_image_dimensions(options)
        w = options[:width] || width
        h = options[:height] || height

        if options[:width] && !options[:height]
          wp = w / width.to_f 
          w = width * wp
          h = height * wp
        elsif options[:height] && !options[:width]         
          hp = h / height.to_f
          w = width * hp
          h = height * hp   
        elsif options[:scale] 
          w = width * options[:scale]
          h = height * options[:scale]
        elsif options[:fit] 
          bw, bh = options[:fit]
          bp = bw / bh.to_f
          ip = width / height.to_f
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

        [w,h]
      end

      def self.find_image_handler_for(content)
        Prawn::Images.constants.each do |handler_name|
          handler = Prawn::Images.const_get handler_name
          next unless handler.respond_to? :can_render?
          return handler if handler.can_render? content
        end
        raise Errors::UnsupportedImageType, "image file is an unrecognised format"
      end
    end
  end
end

