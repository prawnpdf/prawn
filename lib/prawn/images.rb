# encoding: ASCII-8BIT
# images.rb : Implements PDF image embedding
#
# Copyright April 2008, James Healy, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'digest/sha1'

module Prawn

  module Images

    # Add the image at filename to the current page. Currently only
    # JPG and PNG files are supported.
    #
    # Arguments:
    # <tt>file</tt>:: path to file or an object that responds to #read
    #
    # Options:
    # <tt>:at</tt>:: an array [x,y] with the location of the top left corner of the image.
    # <tt>:position</tt>::  One of (:left, :center, :right) or an x-offset
    # <tt>:vposition</tt>::  One of (:top, :center, :center) or an y-offset    
    # <tt>:height</tt>:: the height of the image [actual height of the image]
    # <tt>:width</tt>:: the width of the image [actual width of the image]
    # <tt>:scale</tt>:: scale the dimensions of the image proportionally
    # <tt>:fit</tt>:: scale the dimensions of the image proportionally to fit inside [width,height]
    # 
    #   Prawn::Document.generate("image2.pdf", :page_layout => :landscape) do     
    #     pigs = "#{Prawn::BASEDIR}/data/images/pigs.jpg" 
    #     image pigs, :at => [50,450], :width => 450                                      
    #
    #     dice = "#{Prawn::BASEDIR}/data/images/dice.png"
    #     image dice, :at => [50, 450], :scale => 0.75 
    #   end   
    #
    # If only one of :width / :height are provided, the image will be scaled
    # proportionally.  When both are provided, the image will be stretched to 
    # fit the dimensions without maintaining the aspect ratio.
    #
    #
    # If :at is provided, the image will be place in the current page but
    # the text position will not be changed.
    #
    #
    # If instead of an explicit filename, an object with a read method is
    # passed as +file+, you can embed images from IO objects and things
    # that act like them (including Tempfiles and open-uri objects).
    #
    #   require "open-uri"
    #
    #   Prawn::Document.generate("remote_images.pdf") do 
    #     image open("http://prawn.majesticseacreature.com/media/prawn_logo.png")
    #   end
    #
    # This method returns an image info object which can be used to check the
    # dimensions of an image object if needed. 
    # (See also: Prawn::Images::PNG , Prawn::Images::JPG)
    # 
    def image(file, options={})
      Prawn.verify_options [:at, :position, :vposition, :height, 
                            :width, :scale, :fit], options

      if file.respond_to?(:read)
        image_content = file.read
      else      
        raise ArgumentError, "#{file} not found" unless File.file?(file)  
        image_content =  File.binread(file)
      end
      
      image_sha1 = Digest::SHA1.hexdigest(image_content)

      # if this image has already been embedded, just reuse it
      if image_registry[image_sha1]
        info = image_registry[image_sha1][:info]
        image_obj = image_registry[image_sha1][:obj]
      else
        # build the image object and embed the raw data
        image_obj = case detect_image_format(image_content)
        when :jpg then
          info = Prawn::Images::JPG.new(image_content)
          build_jpg_object(image_content, info)
        when :png then
          info = Prawn::Images::PNG.new(image_content)
          build_png_object(image_content, info)
        end
        image_registry[image_sha1] = {:obj => image_obj, :info => info}
      end

      # find where the image will be placed and how big it will be  
      w,h = calc_image_dimensions(info, options)

      if options[:at]     
        x,y = map_to_absolute(options[:at]) 
      else                  
        x,y = image_position(w,h,options) 
        move_text_position h   
      end

      # add a reference to the image object to the current page
      # resource list and give it a label
      label = "I#{next_image_id}"
      page.xobjects.merge!( label => image_obj )

      # add the image to the current page
      instruct = "\nq\n%.3f 0 0 %.3f %.3f %.3f cm\n/%s Do\nQ"
      add_content instruct % [ w, h, x, y - h, label ]
      
      return info
    end

    private   
    
    def image_position(w,h,options)
      options[:position] ||= :left
      
      x = case options[:position] 
      when :left
        bounds.absolute_left
      when :center
        bounds.absolute_left + (bounds.width - w) / 2.0 
      when :right
        bounds.absolute_right - w
      when Numeric
        options[:position] + bounds.absolute_left
      end

      y = case options[:vposition]
      when :top
        bounds.absolute_top
      when :center
        bounds.absolute_top - (bounds.height - h) / 2.0
      when :bottom
        bounds.absolute_bottom + h
      when Numeric
        bounds.absolute_top - options[:vposition]
      else
        self.y
      end
      return [x,y]
    end

    def build_jpg_object(data, jpg) 
      color_space = case jpg.channels
      when 1
        :DeviceGray
      when 3
        :DeviceRGB
      when 4
        :DeviceCMYK
      else
        raise ArgumentError, 'JPG uses an unsupported number of channels'
      end
      obj = ref!(:Type       => :XObject,
          :Subtype          => :Image,
          :Filter           => :DCTDecode,
          :ColorSpace       => color_space,
          :BitsPerComponent => jpg.bits,
          :Width            => jpg.width,
          :Height           => jpg.height,
          :Length           => data.size ) 

      # add extra decode params for CMYK images. By swapping the
      # min and max values from the default, we invert the colours. See
      # section 4.8.4 of the spec.
      if color_space == :DeviceCMYK
        obj.data[:Decode] = [ 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0 ]
      end

      obj << data
      return obj
    end

    def build_png_object(data, png)

      if png.compression_method != 0
        raise Errors::UnsupportedImageType, 'PNG uses an unsupported compression method'
      end

      if png.filter_method != 0
        raise Errors::UnsupportedImageType, 'PNG uses an unsupported filter method'
      end

      if png.interlace_method != 0
        raise Errors::UnsupportedImageType, 'PNG uses unsupported interlace method'
      end

      # some PNG types store the colour and alpha channel data together,
      # which the PDF spec doesn't like, so split it out.
      png.split_alpha_channel!

      case png.colors
      when 1
        color = :DeviceGray
      when 3
        color = :DeviceRGB
      else
        raise Errors::UnsupportedImageType, "PNG uses an unsupported number of colors (#{png.colors})"
      end

      # build the image dict
      obj = ref!(:Type             => :XObject,
                :Subtype          => :Image,
                :Height           => png.height,
                :Width            => png.width,
                :BitsPerComponent => png.bits,
                :Length           => png.img_data.size,
                :Filter           => :FlateDecode
               )

      unless png.alpha_channel
        obj.data[:DecodeParms] = {:Predictor => 15,
                                  :Colors    => png.colors,
                                  :BitsPerComponent => png.bits,
                                  :Columns   => png.width}
      end

      # append the actual image data to the object as a stream
      obj << png.img_data
      
      # sort out the colours of the image
      if png.palette.empty?
        obj.data[:ColorSpace] = color
      else
        # embed the colour palette in the PDF as a object stream
        palette_obj = ref!(:Length => png.palette.size)
        palette_obj << png.palette

        # build the color space array for the image
        obj.data[:ColorSpace] = [:Indexed, 
                                 :DeviceRGB,
                                 (png.palette.size / 3) -1,
                                 palette_obj]
      end

      # *************************************
      # add transparency data if necessary
      # *************************************

      # For PNG color types 0, 2 and 3, the transparency data is stored in
      # a dedicated PNG chunk, and is exposed via the transparency attribute
      # of the PNG class.
      if png.transparency[:grayscale]
        # Use Color Key Masking (spec section 4.8.5)
        # - An array with N elements, where N is two times the number of color
        #   components.
        val = png.transparency[:grayscale]
        obj.data[:Mask] = [val, val]
      elsif png.transparency[:rgb]
        # Use Color Key Masking (spec section 4.8.5)
        # - An array with N elements, where N is two times the number of color
        #   components.
        rgb = png.transparency[:rgb]
        obj.data[:Mask] = rgb.collect { |x| [x,x] }.flatten
      elsif png.transparency[:indexed]
        # TODO: broken. I was attempting to us Color Key Masking, but I think
        #       we need to construct an SMask i think. Maybe do it inside
        #       the PNG class, and store it in alpha_channel
        #obj.data[:Mask] = png.transparency[:indexed]
      end

      # For PNG color types 4 and 6, the transparency data is stored as a alpha
      # channel mixed in with the main image data. The PNG class seperates
      # it out for us and makes it available via the alpha_channel attribute
      if png.alpha_channel
        min_version 1.4
        smask_obj = ref!(:Type             => :XObject,
                        :Subtype          => :Image,
                        :Height           => png.height,
                        :Width            => png.width,
                        :BitsPerComponent => png.bits,
                        :Length           => png.alpha_channel.size,
                        :Filter           => :FlateDecode,
                        :ColorSpace       => :DeviceGray,
                        :Decode           => [0, 1]
                       )
        smask_obj << png.alpha_channel
        obj.data[:SMask] = smask_obj
      end

      return obj
    end

    def calc_image_dimensions(info, options)
      w = options[:width] || info.width
      h = options[:height] || info.height

      if options[:width] && !options[:height]
        wp = w / info.width.to_f 
        w = info.width * wp
        h = info.height * wp
      elsif options[:height] && !options[:width]         
        hp = h / info.height.to_f
        w = info.width * hp
        h = info.height * hp   
      elsif options[:scale] 
        w = info.width * options[:scale]
        h = info.height * options[:scale]
      elsif options[:fit] 
        bw, bh = options[:fit]
        bp = bw / bh.to_f
        ip = info.width / info.height.to_f
        if ip > bp
          w = bw
          h = bw / ip
        else
          h = bh
          w = bh * ip
        end
      end
      info.scaled_width = w
      info.scaled_height = h
      [w,h]
    end

    def detect_image_format(content)
      top = content[0,128]                       

      if top[0, 3] == "\xff\xd8\xff"
        return :jpg
      elsif top[0, 8]  == "\x89PNG\x0d\x0a\x1a\x0a"
        return :png
      else
        raise Errors::UnsupportedImageType, "image file is an unrecognised format"
      end
    end

    def image_registry
      @image_registry ||= {}
    end

    def next_image_id
      @image_counter ||= 0
      @image_counter += 1
    end
  end
end
