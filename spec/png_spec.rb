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
    @filename = "#{Prawn::DATADIR}/images/web-links.png"
    @data_filename = "#{Prawn::DATADIR}/images/web-links.dat"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    expect(png.width).to eq(21)
    expect(png.height).to eq(14)
    expect(png.bits).to eq(8)
    expect(png.color_type).to eq(0)
    expect(png.compression_method).to eq(0)
    expect(png.filter_method).to eq(0)
    expect(png.interlace_method).to eq(0)
  end

  it "should read the image data chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    data = Zlib::Inflate.inflate(File.binread(@data_filename))
    expect(png.img_data).to eq(data)
  end
end

describe "When reading a greyscale PNG file with transparency (color type 0)" do
  before(:each) do
    @filename = "#{Prawn::DATADIR}/images/ruport_type0.png"
    @img_data = File.binread(@filename)
  end

  # In a greyscale type 0 PNG image, the tRNS chunk should contain a single value
  # that indicates the color that should be interpreted as transparent.
  #
  # http://www.w3.org/TR/PNG/#11tRNS
  it "should read the tRNS chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    expect(png.transparency[:grayscale]).to eq(255)
  end
end

describe "When reading an RGB PNG file (color type 2)" do
  before(:each) do
    @filename = "#{Prawn::DATADIR}/images/ruport.png"
    @data_filename = "#{Prawn::DATADIR}/images/ruport_data.dat"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    expect(png.width).to eq(258)
    expect(png.height).to eq(105)
    expect(png.bits).to eq(8)
    expect(png.color_type).to eq(2)
    expect(png.compression_method).to eq(0)
    expect(png.filter_method).to eq(0)
    expect(png.interlace_method).to eq(0)
  end

  it "should read the image data chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    data = Zlib::Inflate.inflate(File.binread(@data_filename))
    expect(png.img_data).to eq(data)
  end
end

describe "When reading an RGB PNG file with transparency (color type 2)" do
  before(:each) do
    @filename = "#{Prawn::DATADIR}/images/arrow2.png"
    @img_data = File.binread(@filename)
  end

  # In a RGB type 2 PNG image, the tRNS chunk should contain a single RGB value
  # that indicates the color that should be interpreted as transparent. In this
  # case it's green.
  #
  # http://www.w3.org/TR/PNG/#11tRNS
  it "should read the tRNS chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    expect(png.transparency[:rgb]).to eq([0, 255, 0])
  end
end

describe "When reading an indexed color PNG file with transparency (color type 3)" do
  it "raises a not supported error" do
    bin = File.binread("#{Prawn::DATADIR}/images/pal_bk.png")
    expect { Prawn::Images::PNG.new(bin) }.to(
      raise_error(Prawn::Errors::UnsupportedImageType))
  end
end

describe "When reading an indexed color PNG file (color type 3)" do
  before(:each) do
    @filename = "#{Prawn::DATADIR}/images/indexed_color.png"
    @data_filename = "#{Prawn::DATADIR}/images/indexed_color.dat"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    expect(png.width).to eq(150)
    expect(png.height).to eq(200)
    expect(png.bits).to eq(8)
    expect(png.color_type).to eq(3)
    expect(png.compression_method).to eq(0)
    expect(png.filter_method).to eq(0)
    expect(png.interlace_method).to eq(0)
  end

  it "should read the image data chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)
    data = Zlib::Inflate.inflate(File.binread(@data_filename))
    expect(png.img_data).to eq(data)
  end
end

describe "When reading a greyscale+alpha PNG file (color type 4)" do
  before(:each) do
    @filename = "#{Prawn::DATADIR}/images/page_white_text.png"
    @color_data_filename = "#{Prawn::DATADIR}/images/page_white_text.color"
    @alpha_data_filename = "#{Prawn::DATADIR}/images/page_white_text.alpha"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    expect(png.width).to eq(16)
    expect(png.height).to eq(16)
    expect(png.bits).to eq(8)
    expect(png.color_type).to eq(4)
    expect(png.compression_method).to eq(0)
    expect(png.filter_method).to eq(0)
    expect(png.interlace_method).to eq(0)
  end

  it "should correctly return the raw image data (with no alpha channel) from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@color_data_filename)
    expect(png.img_data).to eq(data)
  end

  it "should correctly extract the alpha channel data from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@alpha_data_filename)
    expect(png.alpha_channel).to eq(data)
  end
end

describe "When reading an RGB+alpha PNG file (color type 6)" do
  before(:each) do
    @filename = "#{Prawn::DATADIR}/images/dice.png"
    @color_data_filename = "#{Prawn::DATADIR}/images/dice.color"
    @alpha_data_filename = "#{Prawn::DATADIR}/images/dice.alpha"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    expect(png.width).to eq(320)
    expect(png.height).to eq(240)
    expect(png.bits).to eq(8)
    expect(png.color_type).to eq(6)
    expect(png.compression_method).to eq(0)
    expect(png.filter_method).to eq(0)
    expect(png.interlace_method).to eq(0)
  end

  it "should correctly return the raw image data (with no alpha channel) from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@color_data_filename)
    expect(png.img_data).to eq(data)
  end

  it "should correctly extract the alpha channel data from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@alpha_data_filename)
    expect(png.alpha_channel).to eq(data)
  end
end

describe "When reading a 16bit RGB+alpha PNG file (color type 6)" do
  before(:each) do
    @filename = "#{Prawn::DATADIR}/images/16bit.png"
    @color_data_filename = "#{Prawn::DATADIR}/images/16bit.color"
    # alpha channel truncated to 8-bit
    @alpha_data_filename = "#{Prawn::DATADIR}/images/16bit.alpha"
    @img_data = File.binread(@filename)
  end

  it "should read the attributes from the header chunk correctly" do
    png = Prawn::Images::PNG.new(@img_data)

    expect(png.width).to eq(32)
    expect(png.height).to eq(32)
    expect(png.bits).to eq(16)
    expect(png.color_type).to eq(6)
    expect(png.compression_method).to eq(0)
    expect(png.filter_method).to eq(0)
    expect(png.interlace_method).to eq(0)
  end

  it "should correctly return the raw image data (with no alpha channel) from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@color_data_filename)
    expect(png.img_data).to eq(data)
  end

  it "should correctly extract the alpha channel data from the image data chunk" do
    png = Prawn::Images::PNG.new(@img_data)
    png.split_alpha_channel!
    data = File.binread(@alpha_data_filename)
    expect(png.alpha_channel).to eq(data)
  end
end
