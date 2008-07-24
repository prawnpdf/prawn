# encoding: utf-8

# imagess.rb : Implements PDF image embedding
#
# Copyright April 2008, James Healy.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'prawn/images/offset_reader'
require 'prawn/images/image_info'

module Prawn

  module Images

    # add the image at filename to the current page.
    # use the :at option to chose the image location
    #
    # Currently only works on *some* JPG files.
    def image(filename, options={})
      raise ArgumentError, "#{filename} not found" unless File.file?(filename)

      image_content = File.open(filename, "rb") { |f| f.read }
      image_info = ::Prawn::Images::ImageInfo.new(image_content)

      # register the fact that the current page uses images
      proc_set :ImageC

      # find where the image will be placed
      x,y = translate(options[:at])

      # build the image object and embed the raw data
      # TODO: need a lot more smarts in the building of this dict. The values
      #       for options like ColorSpace and Filter depend on the image file.
      # TODO: What's the best way to get the necessary info from the image file
      #       without resorting to imagemagick and other scary dependencies?
      #       Maybe check PDF::Writer for ideas.
      case image_info.format
      when "JPEG" then
        image_obj = build_jpg_object(image_info, image_content.size)
      else
        raise ArgumentError, "Unsupported Image Type"
      end


      image_obj << image_content

      # add a reference to the image object to the current page
      # resource list and give it a label
      label = "I#{next_image_id}"
      page_xobjects.merge!( label => image_obj )

      # add the image to the current page
      instruct = "\nq\n%.3f 0 0 %.3f %.3f %.3f cm\n/%s Do\nQ"
      add_content instruct % [ image_info.width, image_info.height, x, y, label ]
    end

    private

    def build_jpg_object(info, size)
      obj = ref(:Type       => :XObject,
                :Subtype    => :Image,
                :ColorSpace => :DeviceRGB,
                :Filter     => :DCTDecode,
                :BitsPerComponent => 8,
                :Width   => info.width,
                :Height  => info.height,
                :Length  => size
               )

      case info.channels
      when 1
        obj.data[:ColorSpace] = :DeviceGray
      when 4
        obj.data[:ColorSpace] = :DeviceCMYK
      else
        obj.data[:ColorSpace] = :DeviceRGB
      end
      obj
    end

    def image_counter
      @image_counter ||= 0
    end

    def next_image_id
      counter = image_counter
      counter += 1
    end
  end
end
