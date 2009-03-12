# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "A text box" do

  before(:each) do
    create_pdf    
    @x      = 100
    @y      = 125
    @width  = 50
    @height = @pdf.font.height * 10
    @text = "Oh hai text box. " * 200    
  end

  it "should have a truncated text" do
    @overflow = :truncate
    create_text_box
    @box.render
    @box.text.should == "Oh hai\ntext box.\n" * 5
  end

  it "should have a height equal to @height" do
    @overflow = :truncate    
    create_text_box
    @box.render    
    @box.height.should == @height     
  end

  it "should add ... to for overflow :ellipses" do
    @overflow = :ellipses
    @height = @pdf.font.height * 2
    @text = "Oh hai text box.\n" * 4
    create_text_box
    @box.render
    @box.text.should == "Oh hai\ntext bo..."
  end

  it "should not fail if height is smaller than 1 line" do
    @text = "a b c d e fgi"
    @width = 30
    @height = @pdf.font.height * 0.5
    @overflow = :ellipses    
    create_text_box
    @box.render
    @box.text.should == ""
  end
  
  def create_text_box
    @box = Prawn::Document::Text::Box.new(@text,
                                          :width    => @width, :height => @height,
                                          :overflow => @overflow,
                                          :at       => [@x, @y],
                                          :for      => @pdf)    
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

  
