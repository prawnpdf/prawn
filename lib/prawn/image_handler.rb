module Prawn
  def self.image_handler
    @image_handler ||= ImageHandler.new
  end

  class ImageHandler
    def initialize
      @handlers = []
    end

    def register(handler)
      @handlers.delete(handler)
      @handlers.push handler
    end

    def register!(handler)
      @handlers.delete(handler)
      @handlers.unshift handler
    end

    def find(image_blob)
      handler = @handlers.find{ |h| h.can_render? image_blob }

      return handler if handler

      raise Prawn::Errors::UnsupportedImageType,
            "image file is an unrecognised format"
    end
  end
end
