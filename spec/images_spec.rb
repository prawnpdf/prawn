# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")
require 'set'
require 'pathname'

describe "the image() function" do
  before(:each) do
    @filename = "#{Prawn::DATADIR}/images/pigs.jpg"
    create_pdf
  end

  it "should only embed an image once, even if it's added multiple times" do
    @pdf.image @filename, :at => [100, 100]
    @pdf.image @filename, :at => [300, 300]

    output = @pdf.render
    images = PDF::Inspector::XObject.analyze(output)
    # there should be 2 images in the page resources
    expect(images.page_xobjects.first.size).to eq(2)
    # but only 1 image xobject
    expect(output.scan(/\/Type \/XObject/).size).to eq(1)
  end

  it "should return the image info object" do
    info =  @pdf.image(@filename)

    expect(info).to be_a_kind_of(Prawn::Images::JPG)

    expect(info.height).to eq(453)
  end

  it "should accept IO objects" do
    file = File.open(@filename, "rb")
    info = @pdf.image(file)

    expect(info.height).to eq(453)
  end

  it "rewinds IO objects to be able to embed them multiply" do
    file = File.open(@filename, "rb")

    @pdf.image(file)
    info = @pdf.image(file)
    expect(info.height).to eq(453)
  end

  it "should accept Pathname objects" do
    info = @pdf.image(Pathname.new(@filename))
    expect(info.height).to eq(453)
  end

  context "setting the length of the bytestream" do
    it "should correctly work with images from Pathname objects" do
      info = @pdf.image(Pathname.new(@filename))
      expect(@pdf).to have_parseable_xobjects
    end

    it "should correctly work with images from IO objects" do
      info = @pdf.image(File.open(@filename, 'rb'))
      expect(@pdf).to have_parseable_xobjects
    end

    it "should correctly work with images from IO objects not set to mode rb" do
      info = @pdf.image(File.open(@filename, 'r'))
      expect(@pdf).to have_parseable_xobjects
    end
  end

  it "should raise_error an UnsupportedImageType if passed a BMP" do
    filename = "#{Prawn::DATADIR}/images/tru256.bmp"
    expect { @pdf.image filename, :at => [100, 100] }.to raise_error(Prawn::Errors::UnsupportedImageType)
  end

  it "should raise_error an UnsupportedImageType if passed an interlaced PNG" do
    filename = "#{Prawn::DATADIR}/images/dice_interlaced.png"
    expect { @pdf.image filename, :at => [100, 100] }.to raise_error(Prawn::Errors::UnsupportedImageType)
  end

  it "should bump PDF version to 1.5 or greater on embedding 16-bit PNGs" do
    @pdf.image "#{Prawn::DATADIR}/images/16bit.png"
    expect(@pdf.state.version).to be >= 1.5
  end

  it "should embed 16-bit alpha channels for 16-bit PNGs" do
    @pdf.image "#{Prawn::DATADIR}/images/16bit.png"

    output = @pdf.render
    expect(output).to match(/\/BitsPerComponent 16/)
    expect(output).not_to match(/\/BitsPerComponent 8/)
  end

  it "should flow an image to a new page if it will not fit on a page" do
    @pdf.image @filename, :fit => [600, 600]
    @pdf.image @filename, :fit => [600, 600]
    output = StringIO.new(@pdf.render, 'r+')
    hash = PDF::Reader::ObjectHash.new(output)
    pages = hash.values.find { |obj| obj.is_a?(Hash) && obj[:Type] == :Pages }[:Kids]
    expect(pages.size).to eq(2)
    expect(hash[pages[0]][:Resources][:XObject].keys).to eq([:I1])
    expect(hash[pages[1]][:Resources][:XObject].keys).to eq([:I2])
  end

  it "should not flow an image to a new page if it will fit on one page" do
    @pdf.image @filename, :fit => [400, 400]
    @pdf.image @filename, :fit => [400, 400]
    output = StringIO.new(@pdf.render, 'r+')
    hash = PDF::Reader::ObjectHash.new(output)
    pages = hash.values.find { |obj| obj.is_a?(Hash) && obj[:Type] == :Pages }[:Kids]
    expect(pages.size).to eq(1)
    expect(Set.new(hash[pages[0]][:Resources][:XObject].keys)).to eq(
      Set.new([:I1, :I2])
    )
  end

  it "should not start a new page just for a stretchy bounding box" do
    @pdf.expects(:start_new_page).times(0)
    @pdf.bounding_box([0, @pdf.cursor], :width => @pdf.bounds.width) do
      @pdf.image @filename
    end
  end

  describe ":fit option" do
    it "should fit inside the defined constraints" do
      info = @pdf.image @filename, :fit => [100, 400]
      expect(info.scaled_width).to be <= 100
      expect(info.scaled_height).to be <= 400

      info = @pdf.image @filename, :fit => [400, 100]
      expect(info.scaled_width).to be <= 400
      expect(info.scaled_height).to be <= 100

      info = @pdf.image @filename, :fit => [604, 453]
      expect(info.scaled_width).to eq(604)
      expect(info.scaled_height).to eq(453)
    end
    it "should move text position" do
      @y = @pdf.y
      info = @pdf.image @filename, :fit => [100, 400]
      expect(@pdf.y).to be < @y
    end
  end

  describe ":at option" do
    it "should not move text position" do
      @y = @pdf.y
      info = @pdf.image @filename, :at => [100, 400]
      expect(@pdf.y).to eq(@y)
    end
  end

  describe ":width option without :height option" do
    it "scales the width and height" do
      info = @pdf.image @filename, :width => 225
      expect(info.scaled_height).to eq(168.75)
      expect(info.scaled_width).to eq(225.0)
    end
  end

  describe ":height option without :width option" do
    it "scales the width and height" do
      info = @pdf.image @filename, :height => 225
      expect(info.scaled_height).to eq(225.0)
      expect(info.scaled_width).to eq(300.0)
    end
  end
end
