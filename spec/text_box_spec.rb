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

  it "render should return truncated text (NOTE: which may have had its whitespace mangled by wrap/unwrap)" do
    @text = "Oh hai text box. " * 25
    @overflow = :truncate
    create_text_box
    excess_text = @box.render
    excess_text.should == "Oh hai text box. " * 20
  end

  it "render should attempt to preserve double newlines in excess text before returning it" do
    line  = "Oh hai text box. "
    @text = line * 10 + "\n\n" + line * 10
    @overflow = :truncate
    create_text_box
    excess_text = @box.render
    excess_text.should == line * 5 + "\n\n" + line * 10
  end

  it "render should attempt to preserve single newlines in excess text before returning it" do
    line  = "Oh hai text box. "
    @text = line * 10 + "\n" + line * 10
    @overflow = :truncate
    create_text_box
    excess_text = @box.render
    excess_text.should == line * 5 + "\n" + line * 10
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

  it "should keep text intact for overflow :expand" do
    @overflow = :expand
    @text = "Oh hai text box.\n" * 4
    @height = 0
    create_text_box
    @box.render
    @box.text.should == "Oh hai\ntext box.\n" * 4    
    @box.height.should == 0
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

  
