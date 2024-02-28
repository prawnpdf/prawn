# encoding: ASCII-8BIT
# frozen_string_literal: true

require 'digest/sha1'
require 'pathname'

module Prawn
  # PDF image embedding.
  module Images
    # @group Stable API

    # Add the image at `file` to the current page. Currently only JPG and
    # PNG files are supported. (Note that processing PNG images with alpha
    # channels can be processor and memory intensive.)
    #
    # If only one of `:width` or `:height` are provided, the image will be
    # scaled proportionally. When both are provided, the image will be stretched
    # to fit the dimensions without maintaining the aspect ratio.
    #
    # @example
    #   Prawn::Document.generate("image2.pdf", page_layout: :landscape) do
    #     pigs = "#{Prawn::DATADIR}/images/pigs.jpg"
    #     image pigs, at: [50,450], width: 450
    #
    #     dice = "#{Prawn::DATADIR}/images/dice.png"
    #     image dice, at: [50, 450], scale: 0.75
    #   end
    #
    # @param file [String, IO]
    #   Path to file or an object that responds to `#read` and `#rewind`.
    # @param options [Hash{Symbol => any}]
    # @option options :at [Array(Number, Number)]
    #   The location of the top left corner of the image. If provided,
    #   the image will be place in the current page but the text position will
    #   not be changed.
    # @option options :position [:left, :center, :right, Number]
    #   Horizontal position relative to the current bounding box.
    # @option options :vposition [:topm :center, :bottom, Number]
    #   Vertical position relative to the current bounding box.
    # @option options :height [Number] (actual height of the image)
    #   The height of the image.
    # @option options :width [Number] (actual width of the image)
    #   The width of the image.
    # @option options :scale [Number]
    #   Scale the dimensions of the image proportionally.
    # @option options :fit [Array(Number, Number)]
    #   Scale the dimensions of the image proportionally to fit
    #   inside the rectangle of specified size (width, height).
    # @return [Prawn::Images::Image]
    #   An image handler. All image handlers provided by Prawn are subclasses of
    #   {Prawn::Images::Image}. This object can be used to check the image
    #   dimensions and get other format-specific information.
    #
    # @see Prawn::Images::PNG
    # @see Prawn::Images::JPG
    def image(file, options = {})
      Prawn.verify_options(
        %i[at position vposition height width scale fit],
        options,
      )

      pdf_obj, info = build_image_object(file)
      embed_image(pdf_obj, info, options)

      info
    end

    # Builds an info object (Prawn::Images::*) and a PDF reference representing
    # the given image. Return a pair: [pdf_obj, info].
    #
    # @private
    def build_image_object(file)
      image_content = verify_and_read_image(file)
      image_sha1 = Digest::SHA1.hexdigest(image_content)

      # if this image has already been embedded, just reuse it
      if image_registry[image_sha1]
        info = image_registry[image_sha1][:info]
        image_obj = image_registry[image_sha1][:obj]
      else
        # Build the image object
        info = Prawn.image_handler.find(image_content).new(image_content)

        # Bump PDF version if the image requires it
        if info.respond_to?(:min_pdf_version)
          renderer.min_version(info.min_pdf_version)
        end

        # Add the image to the PDF and register it in case we see it again.
        image_obj = info.build_pdf_object(self)
        image_registry[image_sha1] = { obj: image_obj, info: info }
      end

      [image_obj, info]
    end

    # Given a PDF image resource `pdf_obj` that has been added to the page's
    # resources and an `info` object (the pair returned from
    # {build_image_object}), embed the image according to the `options` given.
    #
    # @private
    def embed_image(pdf_obj, info, options)
      # find where the image will be placed and how big it will be
      w, h = info.calc_image_dimensions(options)

      if options[:at]
        x, y = map_to_absolute(options[:at])
      else
        x, y = image_position(w, h, options)
        move_text_position(h)
      end

      # add a reference to the image object to the current page
      # resource list and give it a label
      label = "I#{next_image_id}"
      state.page.xobjects[label] = pdf_obj

      cm_params = PDF::Core.real_params([w, 0, 0, h, x, y - h])
      renderer.add_content("\nq\n#{cm_params} cm\n/#{label} Do\nQ")
    end

    private

    def verify_and_read_image(io_or_path)
      # File or IO
      if io_or_path.respond_to?(:rewind)
        io = io_or_path
        # Rewind if the object we're passed is an IO, so that multiple embeds of
        # the same IO object will work
        io.rewind
        # read the file as binary so the size is calculated correctly
        # guard binmode because some objects acting io-like don't implement it
        io.binmode if io.respond_to?(:binmode)
        return io.read
      end
      # String or Pathname
      io_or_path = Pathname.new(io_or_path)
      raise ArgumentError, "#{io_or_path} not found" unless io_or_path.file?

      io_or_path.binread
    end

    def image_position(width, height, options)
      options[:position] ||= :left

      y =
        case options[:vposition]
        when :top
          bounds.absolute_top
        when :center
          bounds.absolute_top - ((bounds.height - height) / 2.0)
        when :bottom
          bounds.absolute_bottom + height
        when Numeric
          bounds.absolute_top - options[:vposition]
        else
          determine_y_with_page_flow(height)
        end

      x =
        case options[:position]
        when :left
          bounds.left_side
        when :center
          bounds.left_side + ((bounds.width - width) / 2.0)
        when :right
          bounds.right_side - width
        when Numeric
          options[:position] + bounds.left_side
        end

      [x, y]
    end

    def determine_y_with_page_flow(height)
      if overruns_page?(height)
        bounds.move_past_bottom
      end
      y
    end

    def overruns_page?(height)
      (y - height) < reference_bounds.absolute_bottom
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
