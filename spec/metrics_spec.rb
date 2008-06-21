require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")   

describe "font metrics" do
  
  it "should make the kerning pairs available" do
    times = Prawn::Font::Metrics["Times-Roman"]
    times.kerning("T", "o").should == -80
    times.kerning("X", "X").should == 0
    times.kerning(nil, "X").should == 0
  end
  
  it "should calculate string width taking into account kerning pairs" do
    times = Prawn::Font::Metrics["Times-Roman"]
    times.string_width("To", 12).should == 13.332
    times.string_width("To", 12, :kerning => true).should == 12.372
  end
  
end