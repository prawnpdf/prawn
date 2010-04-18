# encoding: ASCII-8BIT

# Spec'ing the PNG class. Not complete yet - still needs to check the
# contents of palette and transparency to ensure they're correct.
# Need to find files that have these sections first.
#
# see http://www.w3.org/TR/PNG/ for a detailed description of the PNG spec,
# particuarly Table 11.1 for the different color types

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "When reading a greyscale PNG file (color type 0)" do

  before(:each) do
    @filename = "#{Prawn::BASEDIR}/data/images/web-links.png"
    @data_filename = "#{Prawn::BASEDIR}/data/images/web-links.dat"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    png.width.should == 21
    png.height.should == 14
    png.bits.should == 8
    png.color_type.should == 0
    png.compression_method.should == 0
    png.filter_method.should == 0
    png.interlace_method.should == 0
  end

  it "should read the image data chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    data = File.binread(@data_filename)
    png.img_data.should == data
  end
end

describe "When reading a greyscale PNG file with transparency (color type 0)" do

  before(:each) do
    @filename = "#{Prawn::BASEDIR}/data/images/ruport_type0.png"
    @img_data = File.binread(@filename)
  end

  # In a greyscale type 0 PNG image, the tRNS chunk should contain a single value
  # that indicates the color that should be interpreted as transparent.
  #
  # http://www.w3.org/TR/PNG/#11tRNS
  it "should read the tRNS chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    png.transparency[:grayscale].should == 255
  end
end

describe "When reading an RGB PNG file (color type 2)" do

  before(:each) do
    @filename = "#{Prawn::BASEDIR}/data/images/ruport.png"
    @data_filename = "#{Prawn::BASEDIR}/data/images/ruport_data.dat"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    png.width.should == 258
    png.height.should == 105
    png.bits.should == 8
    png.color_type.should == 2
    png.compression_method.should == 0
    png.filter_method.should == 0
    png.interlace_method.should == 0
  end

  it "should read the image data chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    data = File.binread(@data_filename)
    png.img_data.should == data
  end
end

describe "When reading an RGB PNG file with transparency (color type 2)" do

  before(:each) do
    @filename = "#{Prawn::BASEDIR}/data/images/arrow2.png"
    @img_data = File.binread(@filename)
  end

  # In a RGB type 2 PNG image, the tRNS chunk should contain a single RGB value
  # that indicates the color that should be interpreted as transparent. In this
  # case it's green.
  #
  # http://www.w3.org/TR/PNG/#11tRNS
  it "should read the tRNS chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    png.transparency[:rgb].should == [0, 255, 0]
  end
end

# TODO: describe "When reading an indexed color PNG file wiih transparency (color type 3)"

describe "When reading an indexed color PNG file (color type 3)" do

  before(:each) do
    @filename = "#{Prawn::BASEDIR}/data/images/rails.png"
    @data_filename = "#{Prawn::BASEDIR}/data/images/rails.dat"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    png.width.should == 50
    png.height.should == 64
    png.bits.should == 8
    png.color_type.should == 3
    png.compression_method.should == 0
    png.filter_method.should == 0
    png.interlace_method.should == 0
  end

  it "should read the image data chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    data = File.binread(@data_filename)
    png.img_data.should == data
  end
end

describe "When reading a greyscale+alpha PNG file (color type 4)" do

  before(:each) do
    @filename = "#{Prawn::BASEDIR}/data/images/page_white_text.png"
    @data_filename = "#{Prawn::BASEDIR}/data/images/page_white_text.dat"
    @alpha_data_filename = "#{Prawn::BASEDIR}/data/images/page_white_text.alpha"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    png.width.should == 16
    png.height.should == 16
    png.bits.should == 8
    png.color_type.should == 4
    png.compression_method.should == 0
    png.filter_method.should == 0
    png.interlace_method.should == 0
  end

  it "should correctly return the raw image data (with no alpha channel) from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@data_filename)
    png.img_data.should == data
  end

  it "should correctly extract the alpha channel data from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@alpha_data_filename)
    png.alpha_channel.should == data
  end
end

describe "When reading an RGB+alpha PNG file (color type 6)" do

  before(:each) do
    @filename = "#{Prawn::BASEDIR}/data/images/dice.png"
    @data_filename = "#{Prawn::BASEDIR}/data/images/dice.dat"
    @alpha_data_filename = "#{Prawn::BASEDIR}/data/images/dice.alpha"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    png.width.should == 320
    png.height.should == 240
    png.bits.should == 8
    png.color_type.should == 6
    png.compression_method.should == 0
    png.filter_method.should == 0
    png.interlace_method.should == 0
  end

  it "should correctly return the raw image data (with no alpha channel) from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@data_filename)
    png.img_data.should == data
  end

  it "should correctly extract the alpha channel data from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@alpha_data_filename)
    png.alpha_channel.should == data
  end
end

describe "When reading a 16bit RGB+alpha PNG file (color type 6)" do

  before(:each) do
    @filename = "#{Prawn::BASEDIR}/data/images/16bit.png"
    @data_filename = "#{Prawn::BASEDIR}/data/images/16bit.dat"
    # alpha channel truncated to 8-bit
    @alpha_data_filename = "#{Prawn::BASEDIR}/data/images/16bit.alpha"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    png.width.should == 32
    png.height.should == 32
    png.bits.should == 16
    png.color_type.should == 6
    png.compression_method.should == 0
    png.filter_method.should == 0
    png.interlace_method.should == 0
  end

  it "should correctly return the raw image data (with no alpha channel) from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@data_filename)
    png.img_data.should == data
  end

  it "should correctly extract the alpha channel data from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@alpha_data_filename)
    png.alpha_channel.should == data
  end
end
