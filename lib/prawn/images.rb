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
      image_obj = case image_info.format
      when "JPEG" then
        build_jpg_object(image_info, image_content)
      when "PNG" then
        build_png_object(image_info, image_content)
      else
        raise ArgumentError, "Unsupported Image Type"
      end


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

    def build_jpg_object(info, image) 
      size = image.size 
      color_space = case info.channels
      when 1
        :DeviceGray
      when 4
        :DeviceCMYK
      else
        :DeviceRGB
      end
      obj = ref(:Type             => :XObject,
          :Subtype          => :Image,     
          :Filter           => :DCTDecode, 
          :ColorSpace       => color_space,
          :BitsPerComponent => info.bits,
          :Width            => info.width,
          :Height           => info.height,
          :Length           => size ) 
      obj << image
      return obj       
    end

    def build_png_object(info, data)  
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
      
      case info.info[:color_type]
      when 3
        ncolor = 1
        color  = :DeviceRGB
      when 2
        ncolor = 3
        color  = :DeviceRGB
      when 0
        ncolor = 1
        color = :DeviceGray
      else
        raise ArgumentError, "PNG has unsupported color type" 
      end                                   

      png = Prawn::Images::PNG.new(data, info.info[:color_type])

      # build the image dict
      obj = ref(:Type             => :XObject,
                :Subtype          => :Image,
                :Height           => info.height,
                :Width            => info.width,
                :BitsPerComponent => info.bits,
                :Length           => png.img_data.size,
                :DecodeParms      => {:Predictor => 15,
                                      :Colors    => ncolor,
                                      :Columns   => info.width},
                :Filter           => :FlateDecode
                
               )

      # append the actual image data to the object as a stream
      obj << png.img_data
      
      # sort out the colours of the image
      if png.palette.empty?
        obj.data[:ColorSpace] = color
      else
        # embed the colour palette in the PDF as a object stream
        palette_obj = ref(:Length => png.palette.size)
        palette_obj << png.palette

        # build the color space array for the image
        obj.data[:ColorSpace] = [:Indexed, 
                                 :DeviceRGB,
                                 (png.palette.size / 3) -1,
                                 palette_obj]

        # add transparency data if necessary
        if png.transparency && png.transparency[:type] == 'indexed'
          obj.data[:Mask] = png.transparency[:data]
        end
      end

      return obj
    end

    def next_image_id
      @image_counter ||= 0
      @image_counter += 1
    end
  end
end
