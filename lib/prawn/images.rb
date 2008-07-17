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

      # register the fact that the current page uses images
      register_proc :ImageC

      # find where the image will be placed
      x,y = translate(options[:at])

      # build the image object and embed the raw data
      # TODO: need a lot more smarts in the building of this dict. The values
      #       for options like ColorSpace and Filter depend on the image file.
      # TODO: What's the best way to get the necessary info from the image file
      #       without resorting to imagemagick and other scary dependencies?
      #       Maybe check PDF::Writer for ideas.
      image_content = File.read(filename)
      w,h = ImageSize.new(image_content).get_size
      image_obj = ref(:Type       => :XObject,
                      :Subtype    => :Image,
                      :ColorSpace => :DeviceRGB,
                      :Filter     => :DCTDecode,
                      :BitsPerComponent => 8,
                      :Width   => w,
                      :Height  => h,
                      :Length  => image_content.size
                      )
      image_obj << image_content

      # add a reference to the image object to the current page
      # resource list and give it a label
      label = "I#{next_image_id}"
      page_xobjects.merge!( label => image_obj )

      # add the image to the current page
      instruct = "\nq\n%.3f 0 0 %.3f %.3f %.3f cm\n/%s Do\nQ"
      add_content instruct % [ w, h, x, y, label ]
    end

    private

    def image_counter
      @image_counter ||= 0
    end

    def next_image_id
      counter = image_counter
      counter += 1
    end
  end
end
