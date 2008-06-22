require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")   

describe "adobe font metrics" do
  
  setup do
    @times = Prawn::Font::Metrics["Times-Roman"]
  end
  
  it "should calculate string width taking into account accented characters" do
    @times.string_width("é", 12).should == @times.string_width("e", 12)
  end
  
  it "should calculate string width taking into account kerning pairs" do
    @times.string_width("To", 12).should == 13.332
    @times.string_width("To", 12, :kerning => true).should == 12.372
    @times.string_width("Tö", 12, :kerning => true).should == 12.372
  end
  
  it "should kern a string" do
    @times.kern("To").should == ["T", -80, "o"]
    @times.kern("Tö").should == ["T", -80, "ö"]
    @times.kern("Technology").should == ["T", -70, "echnology"]
  end
  
end