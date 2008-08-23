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
end

