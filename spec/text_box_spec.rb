# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "A text box" do

  before(:each) do
    create_pdf    
    @x      = 100
    @y      = 125
    @width  = 50
    @height = 75
    @box = Prawn::Document::Text::Box.new("Oh hai text box. " * 200,
                                                            :width    => @width, :height => @pdf.font.height * 10,
                                                            :overflow => :truncate,
                                                            :at       => [@x, @y],
                                                            :for      => @pdf)
  end

  it "should have a truncated text" do
    @box.render
    @box.text.should == "Oh hai\ntext box.\n" * 5
  end

  it "should add ... to for overflow :ellipses" do
    @box = Prawn::Document::Text::Box.new("Oh hai text box. " * 200,
                                                            :width    => 50, :height => @pdf.font.height * 2,
                                                            :overflow => :ellipses,
                                                            :at       => [@x, @y],
                                                            :for      => @pdf)
    @box.render
    @box.text.should == "Oh hai\ntext bo..."
  end

  it "should not fail if height is smaller than 1 line" do
    @box = Prawn::Document::Text::Box.new("a b c d e fgi",
                                                            :width    => 30, :height => @pdf.font.height * 0.5,
                                                            :overflow => :ellipses,
                                                            :at       => [@x, @y],
                                                            :for      => @pdf)
    @box.render
    @box.text.should == ""
  end

  it "should have a height equal to @height" do
    @box.render    
    @box.height.should == @pdf.font.height * 10     
  end

end

describe "drawing bounding boxes" do    
  
  before(:each) { create_pdf }   

  it "should restore the margin box when bounding box exits" do
    margin_box = @pdf.bounds

    @pdf.text_box "Oh hai text box. " * 11, :height => @pdf.font.height * 10

    @pdf.bounds.should == margin_box

  end
  
end

  
