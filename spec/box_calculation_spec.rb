# encoding: utf-8     

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "A bounding box" do

  before(:each) { create_pdf }
  
  it "should calculate a height if none is specified" do
    @pdf.bounding_box([100, 500], :width => 100) do
      @pdf.text "The rain in Spain falls mainly on the plains."
    end
    
    @pdf.y.should.be.close 458.384, 0.001 
  end

end
