require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "A bounding box" do

  before(:each) { create_pdf }
  
  it "should calculate a height if none is specified" do
    box = @pdf.bounding_box([100, 500], :width => 100) do
      @pdf.text "The rain in Spain falls mainly on the plains."
    end
    
    box.height.should == 36
  end

end
