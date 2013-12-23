# encoding: utf-8

# Spec'ing the PNG class. Not complete yet - still needs to check the
# contents of palette and transparency to ensure they're correct.
# Need to find files that have these sections first.

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "When reading a JPEG file" do

  before(:each) do
    @filename = "#{Prawn::DATADIR}/images/pigs.jpg"
    @img_data = File.open(@filename, "rb") { |f| f.read }
  end

  it "should read the basic attributes correctly" do
    jpg = Prawn::Images::JPG.new(@img_data)

    jpg.width.should == 604
    jpg.height.should == 453
    jpg.bits.should == 8
    jpg.channels.should == 3
  end
end

