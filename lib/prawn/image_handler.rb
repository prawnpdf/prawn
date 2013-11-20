class Prawn::ImageHandler
  @handlers = []

  def self.register(handler)
    unregister(handler)
    @handlers.push handler
  end

  def self.register!(handler)
    unregister(handler)
    @handlers.unshift handler
  end

  def self.unregister(handler)
    @handlers -= [handler]
  end

  def self.find(image_blob)
    handler = @handlers.find{ |h| h.can_render? image_blob }
    if handler
      return handler.new image_blob
    else
      raise Prawn::Errors::UnsupportedImageType, "image file is an unrecognised format"
    end
  end
end
