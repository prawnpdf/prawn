require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")   

describe "font metrics" do
  
  it "should calculate string width taking into account kerning pairs" do
    times = Prawn::Font::Metrics["Times-Roman"]
    times.string_width("To", 12).should == 12.372
    times.string_width("To", 12, :kerning_pairs => false).should == 13.332
  end
  
end