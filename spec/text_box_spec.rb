# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")


describe "Text::Box" do
  it "should not fail if height is smaller than 1 line" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = {
      :height => @pdf.font.height * 0.5,
      :document => @pdf
    }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    text_box.text.should == ""
  end
end

describe "Text::Box#render" do
  it "should draw content to the page" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render()
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.should.not.be.empty
  end
end

describe "Text::Box#render(:dry_run => true)" do
  it "should not draw any content to the page" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render(:dry_run => true)
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.should.be.empty
  end
end

describe "Text::Box default height" do
  it "should be the height from the bottom bound to document.y" do
    create_pdf
    target_height = @pdf.y - @pdf.bounds.bottom
    @text = "Oh hai\n" * 60
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    text_box.height.should.be.close(target_height, @pdf.font.height)
  end
end

describe "Text::Box default at" do
  it "should be the left corner of the bounds, and the current document.y" do
    create_pdf
    target_at = [@pdf.bounds.left, @pdf.y]
    @text = "Oh hai text rect. " * 100
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    text_box.at.should == target_at
  end
end

describe "Text::Box with text than can fit in the box" do
  before(:each) do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = {
      :width => 162.0,
      :height => 162.0,
      :document => @pdf
    }
  end
  
  it "printed text should match requested text, except for trailing or leading white space and that spaces may be replaced by newlines" do
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    text_box.text.gsub("\n", " ").should == @text.strip
  end
  
  it "render should return an empty string because no text remains unprinted" do
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render.should == ""
  end

  it "should be truncated when the leading is set high enough to prevent all the lines from being printed" do
    @options[:leading] = 40
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    text_box.text.gsub("\n", " ").should.not == @text.strip
  end
end

describe "Text::Box with text than can fit in the box with :ellipses overflow and :valign => :bottom" do
  it "should not print ellipses" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = {
      :width => 162.0,
      :height => 162.0,
      :overflow => :ellipses,
      :valign => :bottom,
      :document => @pdf
    }
    @text_box = Prawn::Text::Box.new(@text, @options)
    @text_box.render
    @text_box.text.should.not =~ /\.\.\./
  end
end

describe "Text::Box with more text than can fit in the box" do
  before(:each) do
    create_pdf    
    @text = "Oh hai text rect. " * 30
    @bounding_height = 162.0
    @options = {
      :width => 162.0,
      :height => @bounding_height,
      :document => @pdf
    }
  end
  
  context "truncated overflow" do
    before(:each) do
      @options[:overflow] = :truncate
      @text_box = Prawn::Text::Box.new(@text, @options)
    end
    it "should not display ellipses" do
      @text_box.render
      @text_box.text.should.not =~ /\.\.\./
    end
    it "should be truncated" do
      @text_box.render
      @text_box.text.gsub("\n", " ").should.not == @text.strip
    end
    it "render should not return an empty string because some text remains unprinted" do
      @text_box.render.should.not == ""
    end
    it "#height should be no taller than the specified height" do
      @text_box.render
      @text_box.height.should.be <= @bounding_height
    end
    it "#height should be within one font height of the specified height" do
      @text_box.render
      @bounding_height.should.be.close(@text_box.height, @pdf.font.height)
    end
  end
  
  context "ellipses overflow" do
    before(:each) do
      @options[:overflow] = :ellipses
      @text_box = Prawn::Text::Box.new(@text, @options)
    end
    it "should display ellipses" do
      @text_box.render
      @text_box.text.should =~ /\.\.\./
    end
    it "render should not return an empty string because some text remains unprinted" do
      @text_box.render.should.not == ""
    end
  end

  context "expand overflow" do
    before(:each) do
      @options[:overflow] = :expand
      @text_box = Prawn::Text::Box.new(@text, @options)
    end
    it "height should expand to encompass all the text (but not exceed the height of the page)" do
      @text_box.render
      @text_box.height.should > @bounding_height
    end
    it "should display the entire string (as long as there was space remaining on the page to print all the text)" do
      @text_box.render
      @text_box.text.gsub("\n", " ").should == @text.strip
    end
    it "render should return an empty string because no text remains unprinted(as long as there was space remaining on the page to print all the text)" do
      @text_box.render.should == ""
    end
  end

  context "shrink_to_fit overflow" do
    before(:each) do
      @options[:overflow] = :shrink_to_fit
      @options[:min_font_size] = 2
      @text_box = Prawn::Text::Box.new(@text, @options)
    end
    it "should display the entire text" do
      @text_box.render
      @text_box.text.gsub("\n", " ").should == @text.strip
    end
    it "render should return an empty string because no text remains unprinted" do
      @text_box.render.should == ""
    end
  end
end

describe "Text::Box with a solid block of Chinese characters" do
  it "printed text should match requested text, except for newlines" do
    create_pdf
    @text = "写中国字" * 10
    @options = {
      :width => 162.0,
      :height => 162.0,
      :document => @pdf
    }
    @pdf.font "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
    @options[:overflow] = :truncate
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    text_box.text.gsub("\n", "").should == @text.strip
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
  before(:each) do
    create_pdf
  end

  it "should wrap text" do
    text = "Please wrap this text about HERE. More text that should be wrapped"
    expect = "Please wrap this text about\nHERE. More text that should be\nwrapped"

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                          :width    => 220,
                                          :overflow => :expand,
                                          :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect end of line when wrapping text" do
    text = "Please wrap only before\nTHIS word. Don't wrap this"
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                          :width    => 220,
                                          :overflow => :expand,
                                          :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect multiple newlines when wrapping text" do
    text = "Please wrap only before THIS\n\nword. Don't wrap this"
    expect= "Please wrap only before\nTHIS\n\nword. Don't wrap this"

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                          :width    => 200,
                                          :overflow => :expand,
                                          :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect multiple newlines when wrapping text when those newlines coincide with a line break" do
    text = "Please wrap only before\n\nTHIS word. Don't wrap this"
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                          :width    => 220,
                                          :overflow => :expand,
                                          :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect initial newlines" do
    text = "\nThis should be on line 2"
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                          :width    => 220,
                                          :overflow => :expand,
                                          :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should wrap lines comprised of a single word of the bounds when wrapping text" do
    text = "You_can_wrap_this_text_HERE"
    expect = "You_can_wrap_this_text_HE\nRE"

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text,
                                          :width    => 180,
                                          :overflow => :expand,
                                          :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should wrap lines comprised of a single word of the bounds when wrapping text" do
    text = '©' * 30

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text, :width => 180,
                                           :overflow => :expand,
                                           :document => @pdf)

    text_box.render

    expected = '©'*25 + "\n" + '©' * 5
    @pdf.font.normalize_encoding!(expected)

    text_box.text.should == expected
  end

  it "should wrap non-unicode strings using single-byte word-wrapping" do
    text = "continúa esforzandote " * 5
    text_box = Prawn::Text::Box.new(text, :width => 180,
                                     :document => @pdf)
    text_box.render
    results_with_accent = text_box.text

    text = "continua esforzandote " * 5
    text_box = Prawn::Text::Box.new(text, :width => 180,
                                     :document => @pdf)
    text_box.render
    results_without_accent = text_box.text

    results_with_accent.first_line.length.should == results_without_accent.first_line.length
  end
  
end
