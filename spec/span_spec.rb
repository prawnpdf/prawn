# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "drawing span" do    
  
  def setup
    Prawn.debug = false
    create_pdf
  end

  def teardown
    Prawn.debug = true
  end

  it "should only accept :position as option in debug mode" do
    Prawn.debug = true
    lambda { @pdf.span(350, {:x => 3}) {} }.should.raise(Prawn::Errors::UnknownOption)
  end

  it "should have raise an error if :position is invalid" do
    lambda { @pdf.span(350, :position => :x) {} }.should.raise(ArgumentError)
  end

  it "should restore the margin box when bounding box exits" do
    margin_box = @pdf.bounds

    @pdf.span(350, :position => :center) do
      @pdf.text "Here's some centered text in a 350 point column. " * 100
    end
    
    @pdf.bounds.should == margin_box
    
  end

  it "should do create a margin box" do
    y = @pdf.y
    margin_box = @pdf.span(350, :position => :center) do
      @pdf.text "Here's some centered text in a 350 point column. " * 100
    end
    
    margin_box.top.should == 792.0
    margin_box.bottom.should == 0    
    
  end  
  
end

  
