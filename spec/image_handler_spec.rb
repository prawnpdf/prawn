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
  let(:image_handler) { Prawn::ImageHandler.new }

  it "registers handlers" do
    image_handler.register TestImageHandlerA
  end

  it "prioritizes image handlers" do
    image_handler.register TestImageHandlerA
    image_handler.register! TestImageHandlerB
    handler = image_handler.find "matches a"
    handler.class.should be(TestImageHandlerB)
  end

  it "finds the image handler for an image" do
    image_handler.register TestImageHandlerA
    handler = image_handler.find "matches a"
    handler.class.should be(TestImageHandlerA)
  end
end
