# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "ImageHandler" do
  let(:image_handler) { Prawn::ImageHandler.new }

  let(:handler_a) { mock("Handler A") }
  let(:handler_b) { mock("Handler B") }

  it "finds the image handler for an image" do
    handler_a.expects(:can_render? => true)

    image_handler.register(handler_a)
    image_handler.register(handler_b)

    handler = image_handler.find("arbitrary blob")
    handler.should == handler_a
  end

  it "can prepend handlers" do
    handler_b.expects(:can_render? => true)

    image_handler.register(handler_a)
    image_handler.register!(handler_b)

    handler = image_handler.find("arbitrary blob")
    handler.should == handler_b
  end

  it "can unregister a handler" do
    handler_b.expects(:can_render? => true)

    image_handler.register(handler_a)
    image_handler.register(handler_b)

    image_handler.unregister(handler_a)

    handler = image_handler.find('arbitrary blob')
    handler.should == handler_b
  end

  it "raises an error when no matching handler is found" do
    handler_a.expects(:can_render? => false)
    handler_b.expects(:can_render? => false)

    image_handler.register(handler_a)
    image_handler.register(handler_b)

    expect { image_handler.find("arbitrary blob") }.
       to(raise_error(Prawn::Errors::UnsupportedImageType))
  end

end
