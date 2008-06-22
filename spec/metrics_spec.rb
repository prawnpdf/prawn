require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")   

describe "font metrics" do
  
  it "should calculate string width taking into account kerning pairs" do
    times = Prawn::Font::Metrics["Times-Roman"]
    times.string_width("To", 12).should == 13.332
    times.string_width("To", 12, :kerning => true).should == 12.372
  end
  
  it "should kern a string" do
    times = Prawn::Font::Metrics["Times-Roman"]
    
    times.kern("To").should == ["T", -80, "o"]
    times.kern("Technology").should == ["T", -70, "echnology"]
  end
  
end