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
    @pdf.image @filename, :at => [100,100]
    @pdf.image @filename, :at => [300,300]

    output = @pdf.render
    images = PDF::Inspector::XObject.analyze(output)
    # there should be 2 images in the page resources
    images.page_xobjects.first.size.should == 2
    # but only 1 image xobject
    output.scan(/\/Type \/XObject/).size.should == 1
  end

  it "should return the image info object" do
    info =  @pdf.image(@filename)

    info.should be_a_kind_of(Prawn::Images::JPG)

    info.height.should == 453
  end

  it "should accept IO objects" do
    file = File.open(@filename, "rb")
    info = @pdf.image(file)

    info.height.should == 453
  end

  it "rewinds IO objects to be able to embed them multiply" do
    file = File.open(@filename, "rb")

    @pdf.image(file)
    info = @pdf.image(file)
    info.height.should == 453
  end

  it "should accept Pathname objects" do
    info = @pdf.image(Pathname.new(@filename))
    info.height.should == 453
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
    lambda { @pdf.image filename, :at => [100,100] }.should raise_error(Prawn::Errors::UnsupportedImageType)
  end

  it "should raise_error an UnsupportedImageType if passed an interlaced PNG" do
    filename = "#{Prawn::DATADIR}/images/dice_interlaced.png"
    lambda { @pdf.image filename, :at => [100,100] }.should raise_error(Prawn::Errors::UnsupportedImageType)
  end

  it "should bump PDF version to 1.5 or greater on embedding 16-bit PNGs" do
    @pdf.image "#{Prawn::DATADIR}/images/16bit.png"
    @pdf.state.version.should >= 1.5
  end

  it "should embed 16-bit alpha channels for 16-bit PNGs" do
    @pdf.image "#{Prawn::DATADIR}/images/16bit.png"

    output = @pdf.render
    output.should =~ /\/BitsPerComponent 16/
    output.should_not =~ /\/BitsPerComponent 8/
  end

  it "should flow an image to a new page if it will not fit on a page" do
    @pdf.image @filename, :fit => [600, 600]
    @pdf.image @filename, :fit => [600, 600]
    output = StringIO.new(@pdf.render, 'r+')
    hash = PDF::Reader::ObjectHash.new(output)
    pages = hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Pages}[:Kids]
    pages.size.should == 2
    hash[pages[0]][:Resources][:XObject].keys.should == [:I1]
    hash[pages[1]][:Resources][:XObject].keys.should == [:I2]
  end

  it "should not flow an image to a new page if it will fit on one page" do
    @pdf.image @filename, :fit => [400, 400]
    @pdf.image @filename, :fit => [400, 400]
    output = StringIO.new(@pdf.render, 'r+')
    hash = PDF::Reader::ObjectHash.new(output)
    pages = hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Pages}[:Kids]
    pages.size.should == 1
    Set.new(hash[pages[0]][:Resources][:XObject].keys).should ==
      Set.new([:I1, :I2])
  end

  it "should not start a new page just for a stretchy bounding box" do
    @pdf.expects(:start_new_page).times(0)
    @pdf.bounding_box([0, @pdf.cursor], :width => @pdf.bounds.width) do
      @pdf.image @filename
    end
  end

  describe ":fit option" do
    it "should fit inside the defined constraints" do
      info = @pdf.image @filename, :fit => [100,400]
      info.scaled_width.should <= 100
      info.scaled_height.should <= 400

      info = @pdf.image @filename, :fit => [400,100]
      info.scaled_width.should <= 400
      info.scaled_height.should <= 100

      info = @pdf.image @filename, :fit => [604,453]
      info.scaled_width.should == 604
      info.scaled_height.should == 453
    end
    it "should move text position" do
      @y = @pdf.y
      info = @pdf.image @filename, :fit => [100,400]
      @pdf.y.should < @y
    end
  end

  describe ":at option" do
    it "should not move text position" do
      @y = @pdf.y
      info = @pdf.image @filename, :at => [100,400]
      @pdf.y.should == @y
    end
  end

end

