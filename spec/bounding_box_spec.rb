require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "A bounding box" do

  before(:each) do
    @box = Prawn::Document::BoundingBox.new( [100,100],  :width  => 50, 
                                                         :height => 75 )
  end

  it "should have an anchor at (x, y - height)" do
    @box.anchor.should == [100,25]           
  end

  it "should have a left boundary of 0" do
    @box.left.should == 0
  end
  
  it "should have a right boundary equal to the width" do
    @box.right.should == 50
  end
  
  it "should have a top boundary of height" do
    @box.top.should == 75
  end
  
  it "should have a bottom boundary of 0" do
    @box.bottom.should == 0
  end
  
  it "should have an absolute left boundary of x" do
    @box.absolute_left.should == 100
  end
  
  it "should have an absolute right boundary of x + width" do
    @box.absolute_right.should == 150
  end
  
  it "should have an absolute top boundary of y" do
    @box.absolute_top.should == 100
  end
  
  it "should have an absolute bottom boundary of y - height" do
    @box.absolute_bottom.should == 25
  end

end
