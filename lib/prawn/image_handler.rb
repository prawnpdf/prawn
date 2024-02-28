# frozen_string_literal: true

module Prawn # rubocop: disable Style/Documentation
  # @group Extension API

  # Image handler.
  #
  # @return [ImageHandler]
  def self.image_handler
    @image_handler ||= ImageHandler.new
  end

  # ImageHandler provides a way to register image processors with Prawn.
  class ImageHandler
    # @private
    def initialize
      @handlers = []
    end

    # Register an image handler.
    #
    # @param handler [Object]
    # @return [void]
    def register(handler)
      @handlers.delete(handler)
      @handlers.push(handler)
    end

    # Register an image handler with the highest priority.
    #
    # @param handler [Object]
    # @return [void]
    def register!(handler)
      @handlers.delete(handler)
      @handlers.unshift(handler)
    end

    # Unregister an image handler.
    #
    # @param handler [Object]
    # @return [void]
    def unregister(handler)
      @handlers.reject! { |h| h == handler }
    end

    # Find an image handler for an image.
    #
    # @param image_blob [String]
    # @return [Object]
    # @raise [Prawn::Errors::UnsupportedImageType] If no image handler were
    #   found for the image.
    def find(image_blob)
      handler = @handlers.find { |h| h.can_render?(image_blob) }

      return handler if handler

      raise Prawn::Errors::UnsupportedImageType,
        'image file is an unrecognised format'
    end
  end
end
