require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "A bounding box" do

  before(:each) do
    @box = Prawn::Document::BoundingBox.new(nil, [100,100], :width  => 50,
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

describe "drawing bounding boxes" do

  it "should restore the margin box when bounding box exits" do
    @pdf = Prawn::Document.new
    margin_box = @pdf.bounds

    @pdf.bounding_box [100,500] do
      #nothing
    end

    @pdf.bounds.should == margin_box

  end

  it "should restore the parent bounding box when calls are nested" do
    @pdf = Prawn::Document.new
    @pdf.bounding_box [100,500], :width => 300, :height => 300 do 

      @pdf.bounds.absolute_top.should  == 500
      @pdf.bounds.absolute_left.should == 100 

      @pdf.bounding_box [50,200], :width => 100, :height => 100 do
        @pdf.bounds.absolute_top.should == 200 
        @pdf.bounds.absolute_left.should == 50
      end

      @pdf.bounds.absolute_top.should  == 500
      @pdf.bounds.absolute_left.should == 100 

    end
  end
end
