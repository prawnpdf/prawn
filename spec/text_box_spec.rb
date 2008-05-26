require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "A text box" do

  before(:each) do
    @box = Prawn::TextBox.new("The rains in Spain fall mainly on the plains", :width => 100)
  end
   
  it "should have a height that changes when the width is changed" do
    h = @box.height
    @box.width = 200
    @box.height.should < h
  end
  
  it "should have a padding of 0 by default" do
    @box.padding.should == 0
  end
  
  it "should have a height that changes when the padding is changed" do
    h = @box.height
    @box.padding = 10
    @box.height.should > h
  end
  
  it "should have a border of 0 by default" do
    @box.border.should == 0
  end
  
end