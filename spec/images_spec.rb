# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "the image() function" do

  before(:each) do
    @filename = "#{Prawn::BASEDIR}/data/images/pigs.jpg" 
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
    
    info.should.be.kind_of(Prawn::Images::JPG)
    
    info.height.should == 453
  end
  
  it "should accept IO objects" do
    file = File.open(@filename, "rb")
    info = @pdf.image(file)
    
    info.height.should == 453
  end

  it "should raise an UnsupportedImageType if passed a BMP" do
    filename = "#{Prawn::BASEDIR}/data/images/tru256.bmp"
    lambda { @pdf.image filename, :at => [100,100] }.should.raise(Prawn::Errors::UnsupportedImageType)
  end

  it "should raise an UnsupportedImageType if passed an interlaced PNG" do
    filename = "#{Prawn::BASEDIR}/data/images/dice_interlaced.png"
    lambda { @pdf.image filename, :at => [100,100] }.should.raise(Prawn::Errors::UnsupportedImageType)
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

