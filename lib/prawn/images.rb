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
      
      palette, idata, trans = do_the_nasty(data,info)   
      
      obj = ref(:Type             => :XObject,
                :Subtype          => :Image,
                :Height           => info.height,
                :Width            => info.width,
                :BitsPerComponent => info.bits,
                :Length           => idata.size,
                :DecodeParms      =>  [ {:Predictor => 15, 
                                         :Colors    => ncolor, 
                                         :Columns     => info.width}],
                :Filter           => :FlateDecode
                
               )
                #:Filter     => :FlateDecode 
      
      unless palette.empty?
        obj.data[:ColorSpace]  = 
          ref [:Indexed, :DeviceRGB,  (palette.size / 3) -1]     
 
 
        obj.data[:ColorSpace] << palette
          
        if trans
          case trans[:type]
          when 'indexed'
            obj.data[:Mask] = trans[:data]
          end
        end
      else
        obj.data[:ColorSpace] = color
      end

      obj << idata     
      return obj
    end   

    def do_the_nasty(data,image_info) 
      data = data.dup
      data.extend(ImageInfo::OffsetReader)

      data.read_o(8)  # Skip the default header

      ok      = true
      length  = data.size
      palette = ""
      idat    = ""

      while ok
        chunk_size  = data.read_o(4).unpack("N")[0]
        section     = data.read_o(4)
        case section
        when 'PLTE'
          palette << data.read_o(chunk_size)
        when 'IDAT'
          idat << data.read_o(chunk_size)
        when 'tRNS'
            # This chunk can only occur once and it must occur after the
            # PLTE chunk and before the IDAT chunk
          trans = {}
          case image_info.info[:color_type]
          when 3
              # Indexed colour, RGB. Each byte in this chunk is an alpha for
              # the palette index in the PLTE ("palette") chunk up until the
              # last non-opaque entry. Set up an array, stretching over all
              # palette entries which will be 0 (opaque) or 1 (transparent).
            trans[:type]  = 'indexed'
            trans[:data]  = data.read_o(chunk_size).unpack("C*")
          when 0
              # Greyscale. Corresponding to entries in the PLTE chunk.
              # Grey is two bytes, range 0 .. (2 ^ bit-depth) - 1
            trans[:grayscale] = data.read_o(2).unpack("n")
            trans[:type]      = 'indexed'
#           trans[:data]      = data.read_o.unpack("C")
          when 2
              # True colour with proper alpha channel.
            trans[:rgb] = data.read_o(6).unpack("nnn")
          end
        else
          data.offset += chunk_size
        end

        ok = (section != "IEND")

        data.read_o(4)  # Skip the CRC
      end

      if image_info.bits > 8
        raise TypeError, PDF::Writer::Lang[:png_8bit_colour]
      end
      if image_info.info[:interlace_method] != 0
        raise TypeError, PDF::Writer::Lang[:png_interlace]
      end        
      [palette,idat,trans]
    end

    def next_image_id
      @image_counter ||= 0
      @image_counter += 1
    end
  end
end
