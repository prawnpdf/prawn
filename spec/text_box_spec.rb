# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Box#extensions" do
  it "should be able to override default line wrapping" do
    create_pdf
    Prawn::Text::Box.extensions << TestWrapOverride
    @pdf.text_box("hello world", {})
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[0].should == "all your base are belong to us"
    Prawn::Text::Box.extensions.delete(TestWrapOverride)
  end
end

describe "Text::Box#render with :align => :justify" do
  it "should draw the character spacing to the document" do
    create_pdf
    string = "hello world " * 10
    options = { :document => @pdf, :align => :justify }
    text_box = Prawn::Text::Box.new(string, options)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.word_spacing[0].should.be > 0
  end
end

describe "Text::Box#height without leading" do
  it "should equal the sum of the height of each line" do
    create_pdf
    text = "Oh hai text rect.\nOh hai text rect."
    options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(text, options)
    text_box.render
    text_box.height.should == @pdf.font.height * 2
  end
end

describe "Text::Box#height with leading" do
  it "should equal the sum of the height of each line" do
    create_pdf
    text = "Oh hai text rect.\nOh hai text rect."
    leading = 12
    options = { :document => @pdf, :leading => leading }
    text_box = Prawn::Text::Box.new(text, options)
    text_box.render
    text_box.height.should == @pdf.font.height * 2 + leading
  end
end

describe "Text::Box#valid_options" do
  it "should return an array" do
    create_pdf
    text_box = Prawn::Text::Box.new("", :document => @pdf)
    text_box.valid_options.should.be.kind_of(Array)
  end
end

describe "Text::Box#render" do
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
  it "should draw content to the page" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.should.not.be.empty
  end
  it "should not draw a transformation matrix" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
    matrices.matrices.length.should == 0
  end
end

describe "Text::Box#render(:single_line => true)" do
  it "should draw only one line to the page" do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf,
                 :single_line => true }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.length.should == 1
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
  it "subsequent calls to render should not raise an ArgumentError exception" do
    create_pdf
    @text = "™©"
    @options = { :document => @pdf }
    text_box = Prawn::Text::Box.new(@text, @options)
    text_box.render(:dry_run => true)
    lambda { text_box.render }.should.not.raise(ArgumentError)
  end
end

describe "Text::Box#render with :rotate option of 30)" do
  before(:each) do
    create_pdf
    rotate = 30
    @x = 300
    @y = 70
    @width = 100
    @height = 50
    @cos = Math.cos(rotate * Math::PI / 180)
    @sin = Math.sin(rotate * Math::PI / 180)
    @text = "Oh hai text rect. " * 10
    @options = { :document => @pdf,
                 :rotate => rotate,
                 :at => [@x, @y],
                 :width => @width,
                 :height => @height }
  end
  context ":rotate_around option of :center" do
    it "should draw content to the page rotated about the center of the text" do
      @options[:rotate_around] = :center
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x + @width / 2
      y = @y - @height / 2
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      matrices.matrices[0].should == [1, 0, 0, 1,
                                      reduce_precision(x - x_prime),
                                      reduce_precision(y - y_prime)]
      matrices.matrices[1].should == [reduce_precision(@cos),
                                      reduce_precision(@sin),
                                      reduce_precision(-@sin),
                                      reduce_precision(@cos), 0, 0]

      text = PDF::Inspector::Text.analyze(@pdf.render)
      text.strings.should.not.be.empty
    end
  end
  context ":rotate_around option of :upper_left" do
    it "should draw content to the page rotated about the upper left corner of the text" do
      @options[:rotate_around] = :upper_left
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x
      y = @y
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      matrices.matrices[0].should == [1, 0, 0, 1,
                                      reduce_precision(x - x_prime),
                                      reduce_precision(y - y_prime)]
      matrices.matrices[1].should == [reduce_precision(@cos),
                                      reduce_precision(@sin),
                                      reduce_precision(-@sin),
                                      reduce_precision(@cos), 0, 0]

      text = PDF::Inspector::Text.analyze(@pdf.render)
      text.strings.should.not.be.empty
    end
  end
  context "default :rotate_around" do
    it "should draw content to the page rotated about the upper left corner of the text" do
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x
      y = @y
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      matrices.matrices[0].should == [1, 0, 0, 1,
                                      reduce_precision(x - x_prime),
                                      reduce_precision(y - y_prime)]
      matrices.matrices[1].should == [reduce_precision(@cos),
                                      reduce_precision(@sin),
                                      reduce_precision(-@sin),
                                      reduce_precision(@cos), 0, 0]

      text = PDF::Inspector::Text.analyze(@pdf.render)
      text.strings.should.not.be.empty
    end
  end
  context ":rotate_around option of :upper_right" do
    it "should draw content to the page rotated about the upper right corner of the text" do
      @options[:rotate_around] = :upper_right
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x + @width
      y = @y
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      matrices.matrices[0].should == [1, 0, 0, 1,
                                      reduce_precision(x - x_prime),
                                      reduce_precision(y - y_prime)]
      matrices.matrices[1].should == [reduce_precision(@cos),
                                      reduce_precision(@sin),
                                      reduce_precision(-@sin),
                                      reduce_precision(@cos), 0, 0]

      text = PDF::Inspector::Text.analyze(@pdf.render)
      text.strings.should.not.be.empty
    end
  end
  context ":rotate_around option of :lower_right" do
    it "should draw content to the page rotated about the lower right corner of the text" do
      @options[:rotate_around] = :lower_right
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x + @width
      y = @y - @height
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      matrices.matrices[0].should == [1, 0, 0, 1,
                                      reduce_precision(x - x_prime),
                                      reduce_precision(y - y_prime)]
      matrices.matrices[1].should == [reduce_precision(@cos),
                                      reduce_precision(@sin),
                                      reduce_precision(-@sin),
                                      reduce_precision(@cos), 0, 0]

      text = PDF::Inspector::Text.analyze(@pdf.render)
      text.strings.should.not.be.empty
    end
  end
  context ":rotate_around option of :lower_left" do
    it "should draw content to the page rotated about the lower left corner of the text" do
      @options[:rotate_around] = :lower_left
      text_box = Prawn::Text::Box.new(@text, @options)
      text_box.render

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      x = @x
      y = @y - @height
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos
      matrices.matrices[0].should == [1, 0, 0, 1,
                                      reduce_precision(x - x_prime),
                                      reduce_precision(y - y_prime)]
      matrices.matrices[1].should == [reduce_precision(@cos),
                                      reduce_precision(@sin),
                                      reduce_precision(-@sin),
                                      reduce_precision(@cos), 0, 0]

      text = PDF::Inspector::Text.analyze(@pdf.render)
      text.strings.should.not.be.empty
    end
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



describe "Text::Box printing UTF-8 string with higher bit characters" do
  before(:each) do
    create_pdf    
    @text = "©"
    # not enough height to print any text, so we can directly compare against
    # the input string
    bounding_height = 1.0
    options = {
      :height => bounding_height,
      :document => @pdf
    }
    file = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
    @pdf.font_families["Action Man"] = {
      :normal      => { :file => file, :font => "ActionMan" },
      :italic      => { :file => file, :font => "ActionMan-Italic" },
      :bold        => { :file => file, :font => "ActionMan-Bold" },
      :bold_italic => { :file => file, :font => "ActionMan-BoldItalic" }
    }
    @text_box = Prawn::Text::Box.new(@text, options)
  end
  describe "when using a TTF font" do
    it "unprinted text should be in UTF-8 encoding" do
      @pdf.font("Action Man")
      remaining_text = @text_box.render
      remaining_text.should == @text
    end
    it "subsequent calls to Text::Box need not include the" +
       " :skip_encoding => true option" do
      @pdf.font("Action Man")
      remaining_text = @text_box.render
      lambda {
        @pdf.text_box(remaining_text, :document => @pdf)
      }.should.not.raise(ArgumentError)
    end
  end
  describe "when using an AFM font" do
    it "unprinted text should be in WinAnsi encoding" do
      remaining_text = @text_box.render
      remaining_text.should == @pdf.font.normalize_encoding(@text)
    end
    it "subsequent calls to Text::Box must include the" +
       " :skip_encoding => true option" do
      remaining_text = @text_box.render
      lambda {
        @pdf.text_box(remaining_text, :document => @pdf)
      }.should.raise(ArgumentError)
      lambda {
        @pdf.text_box(remaining_text, :skip_encoding => true,
                                      :document => @pdf)
      }.should.not.raise(ArgumentError)
    end
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
    context "with :rotate option" do
      it "unrendered text should be the same as when not rotated" do
        remaining_text = @text_box.render

        rotate = 30
        x = 300
        y = 70
        width = @options[:width]
        height = @options[:height]
        @options[:document] = @pdf
        @options[:rotate] = rotate
        @options[:at] = [x, y]
        rotated_text_box = Prawn::Text::Box.new(@text, @options)
        rotated_text_box.render.should == remaining_text
      end
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

  
describe "Text::Box wrapping" do
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
    text = "©" * 30

    @pdf.font "Courier"
    text_box = Prawn::Text::Box.new(text, :width => 180,
                                           :overflow => :expand,
                                           :document => @pdf)

    text_box.render

    expected = "©" * 25 + "\n" + "©" * 5
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

def reduce_precision(float)
  ("%.5f" % float).to_f
end

module TestWrapOverride
  def wrap(string)
    @text = nil
    @line_height = @document.font.height
    @descender   = @document.font.descender
    @ascender    = @document.font.ascender
    @baseline_y  = -@ascender
    draw_line("all your base are belong to us")
    ""
  end
end
