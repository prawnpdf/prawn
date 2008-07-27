# encoding: utf-8

# Spec'ing the PNG class. Not complete yet - still needs to check the
# contents of palette and transparency to ensure they're correct.
# Need to find files that have these sections first.

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "When reading an RGB PNG file" do

  before(:each) do
    @filename = "#{Prawn::BASEDIR}/data/images/ruport.png"
    @data_filename = "#{Prawn::BASEDIR}/data/images/ruport_data.dat"
    @img_data = File.open(@filename, "rb") { |f| f.read }
  end
   
  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    
    png.width.should eql(258)
    png.height.should eql(105)
    png.bits.should eql(8)
    png.color_type.should eql(2)
    png.compression_method.should eql(0)
    png.filter_method.should eql(0)
    png.interlace_method.should eql(0)
  end

  it "should read the image data chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    data = File.open(@data_filename) { |f| f.read }
    png.img_data.should eql(data)
  end  
end

