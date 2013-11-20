# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

class TestImageHandlerBase
  def self.can_render?(image_blob)
    image_blob =~ /^matches a/
  end

  def initialize(image_blob)
  end
end

class TestImageHandlerA < TestImageHandlerBase
end

class TestImageHandlerB < TestImageHandlerBase
end

describe "ImageHandler" do
  after(:each) do
    Prawn::ImageHandler.unregister TestImageHandlerA
    Prawn::ImageHandler.unregister TestImageHandlerB
  end

  it "registers handlers" do
    Prawn::ImageHandler.register TestImageHandlerA
  end

  it "prioritizes image handlers" do
    Prawn::ImageHandler.register TestImageHandlerA
    Prawn::ImageHandler.register! TestImageHandlerB
    handler = Prawn::ImageHandler.find "matches a"
    handler.class.should be(TestImageHandlerB)
  end

  it "finds the image handler for an image" do
    Prawn::ImageHandler.register TestImageHandlerA
    handler = Prawn::ImageHandler.find "matches a"
    handler.class.should be(TestImageHandlerA)
  end

  it "unregisters handlers" do
    Prawn::ImageHandler.register TestImageHandlerA
    Prawn::ImageHandler.unregister TestImageHandlerA
    lambda {
      Prawn::ImageHandler.find "matches a"
    }.should raise_error(Prawn::Errors::UnsupportedImageType)
  end
end
