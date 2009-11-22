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
    @box.text.should == ("Oh hai\ntext box.\n" * 5).rstrip
  end

  it "render should return truncated text (NOTE: which may have had its whitespace mangled by wrap/unwrap)" do
    @text = "Oh hai text box. " * 25
    @overflow = :truncate
    create_text_box
    excess_text = @box.render
    excess_text.should == ("Oh hai text box. " * 20).rstrip
  end

  it "render should attempt to preserve double newlines in excess text before returning it" do
    line  = "Oh hai text box. "
    @text = line * 10 + "\n\n" + line * 10
    @overflow = :truncate
    create_text_box
    excess_text = @box.render
    excess_text.should == (line * 5 + "\n\n" + line * 10).rstrip
  end

  it "render should attempt to preserve single newlines in excess text before returning it" do
    line  = "Oh hai text box. "
    @text = line * 10 + "\n" + line * 10
    @overflow = :truncate
    create_text_box
    excess_text = @box.render
    excess_text.should == (line * 5 + "\n" + line * 10).rstrip
  end

  it "should have a height equal to @height" do
    @overflow = :truncate    
    create_text_box
    @box.render    
    @box.height.should.be.close(@height, 0.0001)
  end

  it "should add ... to for overflow :ellipses" do
    @overflow = :ellipses
    @height = @pdf.font.height * 2
    @text = "Oh hai text box.\n" * 4
    create_text_box
    @box.render
    @box.text.should == "Oh hai\ntext b..."
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
    @box.text.should == ("Oh hai\ntext box.\n" * 4).rstrip
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

  









describe 'Text::Box wrapping' do
  

  it "should wrap text" do
    text = "Please wrap this text about HERE. More text that should be wrapped"
    expect = "Please wrap this text about\nHERE. More text that should be\nwrapped"

    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    @box = Prawn::Document::Text::Box.new(text,
                                          :width    => 220,
                                          :overflow => :expand,
                                          :for      => @pdf)
    @box.render
    @box.text.should == expect
  end

  it "should respect end of line when wrapping text" do
    text = "Please wrap only before\nTHIS word. Don't wrap this"
    expect = text

    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    @box = Prawn::Document::Text::Box.new(text,
                                          :width    => 220,
                                          :overflow => :expand,
                                          :for      => @pdf)
    @box.render
    @box.text.should == expect
  end

  it "should respect multiple newlines when wrapping text" do
    text = "Please wrap only before THIS\n\nword. Don't wrap this"
    expect= "Please wrap only before\nTHIS\n\nword. Don't wrap this"

    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    @box = Prawn::Document::Text::Box.new(text,
                                          :width    => 200,
                                          :overflow => :expand,
                                          :for      => @pdf)
    @box.render
    @box.text.should == expect
  end

  it "should respect multiple newlines when wrapping text when those newlines coincide with a line break" do
    text = "Please wrap only before\n\nTHIS word. Don't wrap this"
    expect = text

    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    @box = Prawn::Document::Text::Box.new(text,
                                          :width    => 220,
                                          :overflow => :expand,
                                          :for      => @pdf)
    @box.render
    @box.text.should == expect
  end

  it "should wrap lines comprised of a single word of the bounds when wrapping text" do
    text = "You_can_wrap_this_text_HERE"
    expect = "You_can_wrap_this_text_HE\nRE"

    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    @box = Prawn::Document::Text::Box.new(text,
                                          :width    => 180,
                                          :overflow => :expand,
                                          :for      => @pdf)
    @box.render
    @box.text.should == expect
  end     
  
end
