# encoding: utf-8

# imagess.rb : Implements PDF image embedding
#
# Copyright April 2008, James Healy.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn

  module Images

    # add the image at filename to the current page.
    # use the :at option to chose the image location
    #
    # Currently only works on *some* JPG files.
    def image(filename, options={})
      raise ArgumentError, "#{filename} not found" unless File.file?(filename)

      image_content = File.open(filename, "rb") { |f| f.read }
      image_info = ImageInfo.new(image_content)

      # register the fact that the current page uses images
      proc_set :ImageC

      # find where the image will be placed
      x,y = translate(options[:at])

      # build the image object and embed the raw data
      case image_info.format
      when "JPEG" then
        image_obj = build_jpg_object(image_info, image_content.size)
      when "PNG" then
        image_obj = build_png_object(image_info, image_content.size)
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
      add_content instruct % [ image_info.width, image_info.height, x, 
                               y - image_info.height, label ]
    end

    private

    def build_jpg_object(info, size)  
      color_space = case info.channels
      when 1
        :DeviceGray
      when 4
        :DeviceCMYK
      else
        :DeviceRGB
      end
      
      ref(:Type             => :XObject,
          :Subtype          => :Image,     
          :Filter           => :DCTDecode, 
          :ColorSpace       => color_space,
          :BitsPerComponent => info.bits,
          :Width            => info.width,
          :Height           => info.height,
          :Length           => size )   
      obj
    end

    def build_png_object(info, size)
      if info.info[:compression_method] != 0
        raise ArgumentError, 'PNG uses an unsupported compression method'
      end

      if info.info[:filter_method] != 0
        raise ArgumentError, 'PNG uses an unsupported filter method'
      end

      if info.info[:interlace_method] != 0
        raise ArgumentError, 'PNG uses unsupported interlace method'
      end

      if info.bits > 8
        raise ArgumentError, 'PNG uses more than 8 bits'
      end

      obj = ref(:Type       => :XObject,
                :Subtype    => :Image,
                :Height     => info.height,
                :Width      => info.width,
                :BitsPerComponent => info.bits,
                :Length     => size
               )
                #:Filter     => :FlateDecode,
      case info.info[:color_type]
      when 3
        ncolor = 1
        color  = :DeviceRGB
      when 2
        ncolor = 3
        color  = :DeviceRGB
      when 0
        ncolor = 1
        colour = :DeviceGray
      else
        raise ArgumentError, "PNG has unsupported color type" 
      end
      obj.data[:DecodeParms] = [{:Predictor => 15, :Colors => ncolor, :Columns => info.width}]
      obj.data[:ColorSpace]  = color
      obj
    end

    def image_counter
      @image_counter ||= 0
    end

    def next_image_id
      @image_counter ||= 0
      @image_counter += 1
    end
  end
end
