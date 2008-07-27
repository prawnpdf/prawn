# encoding: utf-8

# images.rb : Implements PDF image embedding
#
# Copyright April 2008, James Healy, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn

  module Images

    # add the image at filename to the current page. Currently only
    # JPG and PNG files are supported.
    #
    # Arguments:
    # <tt>filename</tt>:: the path to the file to be embedded
    #
    # Options:
    # <tt>:at</tt>:: the location of the top left corner of the image [current position]
    # <tt>:height</tt>:: the height of the image [actual height of the image]
    # <tt>:width</tt>:: the width of the image [actual width of the image]
    # <tt>:scale</tt>:: scale the dimensions of the image proportionally
    #
    def image(filename, options={})
      raise ArgumentError, "#{filename} not found" unless File.file?(filename)

      image_content = File.open(filename, "rb") { |f| f.read }

      # register the fact that the current page uses images
      proc_set :ImageC

      # build the image object and embed the raw data
      image_obj = case detect_image_format(image_content)
      when :jpg then
        info = Prawn::Images::Jpg.new(image_content)
        build_jpg_object(image_content, info)
      when :png then
        info = Prawn::Images::PNG.new(image_content)
        build_png_object(image_content, info)
      end

      # find where the image will be placed and how big it will be
      x,y = translate(options[:at])
      w,h = calc_image_dimensions(info, options)

      # add a reference to the image object to the current page
      # resource list and give it a label
      label = "I#{next_image_id}"
      page_xobjects.merge!( label => image_obj )

      # add the image to the current page
      instruct = "\nq\n%.3f 0 0 %.3f %.3f %.3f cm\n/%s Do\nQ"
      add_content instruct % [ w, h, x, y - h, label ]
    end

    private

    def build_jpg_object(data, jpg) 
      color_space = case jpg.channels
      when 1
        :DeviceGray
      when 4
        :DeviceCMYK
      else
        :DeviceRGB
      end
      obj = ref(:Type       => :XObject,
          :Subtype          => :Image,
          :Filter           => :DCTDecode,
          :ColorSpace       => color_space,
          :BitsPerComponent => jpg.bits,
          :Width            => jpg.width,
          :Height           => jpg.height,
          :Length           => data.size ) 
      obj << data
      return obj
    end

    def build_png_object(data, png)
      png = Prawn::Images::PNG.new(data)

      if png.compression_method != 0
        raise ArgumentError, 'PNG uses an unsupported compression method'
      end

      if png.filter_method != 0
        raise ArgumentError, 'PNG uses an unsupported filter method'
      end

      if png.interlace_method != 0
        raise ArgumentError, 'PNG uses unsupported interlace method'
      end

      if png.bits > 8
        raise ArgumentError, 'PNG uses more than 8 bits'
      end
      
      case png.color_type
      when 0
        ncolor = 1
        color = :DeviceGray
      when 2
        ncolor = 3
        color  = :DeviceRGB
      when 3
        ncolor = 1
        color  = :DeviceRGB
      else
        raise ArgumentError, "PNG has unsupported color type" 
      end                                   

      # build the image dict
      obj = ref(:Type             => :XObject,
                :Subtype          => :Image,
                :Height           => png.height,
                :Width            => png.width,
                :BitsPerComponent => png.bits,
                :Length           => png.img_data.size,
                :DecodeParms      => {:Predictor => 15,
                                      :Colors    => ncolor,
                                      :Columns   => png.width},
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
        #if png.transparency && png.transparency[:type] == 'indexed'
        #  obj.data[:Mask] = png.transparency[:data]
        #end
      end

      return obj
    end

    def calc_image_dimensions(info, options)
      # TODO: allow the image to be aligned in a box
      w = options[:width] || info.width
      h = options[:height] || info.height

      if options[:scale] && (options[:width] || options[:height])
        wp = w / info.width.to_f
        hp = h / info.height.to_f

        if wp < hp
          w = info.width * wp
          h = info.height * wp
        else
          w = info.width * hp
          h = info.height * hp
        end
      end

      [w,h]
    end

    def detect_image_format(content)
      top = content[0,128]

      if top[0, 3]  == "\xff\xd8\xff"
        return :jpg
      elsif top[0, 8]  == "\x89PNG\x0d\x0a\x1a\x0a"
        return :png
      else
        raise ArgumentError, "Unsupported Image Type"
      end
    end

    def next_image_id
      @image_counter ||= 0
      @image_counter += 1
    end
  end
end
