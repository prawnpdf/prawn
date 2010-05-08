# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Formatted::Box#extensions" do
  it "should be able to override default line wrapping" do
    create_pdf
    Prawn::Text::Formatted::Box.extensions << TestFormattedWrapOverride
    @pdf.formatted_text_box([{ :text => "hello world" }], {})
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[0].should == "all your base are belong to us"
    Prawn::Text::Formatted::Box.extensions.delete(TestFormattedWrapOverride)
  end
  it "overriding Text::Box line wrapping should not affect " +
     "Text::Formatted::Box wrapping" do
    create_pdf
    Prawn::Text::Box.extensions << TestWrapOverride
    @pdf.formatted_text_box([{ :text => "hello world" }], {})
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[0].should == "hello world"
    Prawn::Text::Box.extensions.delete(TestWrapOverride)
  end
end

describe "Text::Formatted::Box#render" do
  it "should handle newlines" do
    create_pdf
    array = [{ :text => "hello\nworld"}]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text_box.text.should == "hello\nworld"
  end
  it "should omit spaces from the beginning of the line" do
    create_pdf
    array = [{ :text => " hello\n world"}]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text_box.text.should == "hello\nworld"
  end
  it "should omit spaces from the end of the line" do
    create_pdf
    array = [{ :text => "hello \nworld "}]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text_box.text.should == "hello\nworld"
  end
  it "should be okay printing a line of whitespace" do
    create_pdf
    array = [{ :text => "hello\n    \nworld "}]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text_box.text.should == "hello\n\nworld"
  end
end

describe "Text::Formatted::Box#render with :align => :justify" do
  it "should draw the character spacing to the document" do
    create_pdf
    array = [{ :text => "hello world " * 10}]
    options = { :document => @pdf, :align => :justify }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.word_spacing[0].should.be > 0
  end
end

describe "Text::Formatted::Box#height without leading" do
  it "should equal the sum of the height of each line" do
    create_pdf
    format_array = [{ :text => "line 1" },
                    { :text => "\n" },
                    { :text => "line 2" }]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(format_array, options)
    text_box.render
    text_box.height.should == @pdf.font.height * 2
  end
end

describe "Text::Formatted::Box#height with leading" do
  it "should equal the sum of the height of each line" +
     " plus all but the last leading" do
    create_pdf
    format_array = [{ :text => "line 1" },
                    { :text => "\n" },
                    { :text => "line 2" }]
    leading = 12
    options = { :document => @pdf, :leading => leading }
    text_box = Prawn::Text::Formatted::Box.new(format_array, options)
    text_box.render
    text_box.height.should == @pdf.font.height * 2 + leading
  end
end

describe "Text::Formatted::Box#render(:single_line => true)" do
  it "should draw only one line to the page" do
    create_pdf
    text = "Oh hai text rect. " * 10
    format_array = [:text => text]
    options = { :document => @pdf,
                 :single_line => true }
    text_box = Prawn::Text::Formatted::Box.new(format_array, options)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.strings.length.should == 1
  end
end

describe "Text::Formatted::Box#render(:dry_run => true)" do
  it "should not draw any content to the page" do
    create_pdf
    text = "Oh hai text rect. " * 10
    format_array = [:text => text]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(format_array, options)
    text_box.render(:dry_run => true)
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.strings.should.be.empty
  end
  it "subsequent calls to render should not raise an ArgumentError exception" do
    create_pdf
    text = "™©"
    format_array = [:text => text]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(format_array, options)
    text_box.render(:dry_run => true)
    lambda { text_box.render }.should.not.raise(ArgumentError)
  end
end

describe "Text::Formatted::Box#render" do
  it "should be able to perform fragment callbacks" do
    create_pdf
    callback_object = TestFragmentCallback.new
    callback_object.expects(:draw_border).with(
                                      kind_of(Prawn::Text::Formatted::Fragment))
    array = [{ :text => "hello world " },
             { :text => "callback now",
               :callback => { :object => callback_object,
                              :method => :draw_border } }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
  end
  it "should be able to perform fragment callbacks with arguments" do
    create_pdf
    callback_object = TestFragmentCallback.new
    callback_object.expects(:draw_border_with_args).with(
               kind_of(Prawn::Text::Formatted::Fragment), "something", 7)
    array = [{ :text => "hello world " },
             { :text => "callback now",
               :callback => { :object => callback_object,
                              :method => :draw_border_with_args,
                              :arguments => ["something", 7] } }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
  end
  it "should be able to set the font" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "Times-Bold",
               :styles => [:bold],
               :font => "Times-Roman" },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    fonts = contents.font_settings.map { |e| e[:name] }
    fonts.should == [:Helvetica, :"Times-Bold", :Helvetica]
    contents.strings[0].should == "this contains "
    contents.strings[1].should == "Times-Bold"
    contents.strings[2].should == " text"
  end
  it "should be able to set bold" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "bold", :styles => [:bold] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    fonts = contents.font_settings.map { |e| e[:name] }
    fonts.should == [:Helvetica, :"Helvetica-Bold", :Helvetica]
    contents.strings[0].should == "this contains "
    contents.strings[1].should == "bold"
    contents.strings[2].should == " text"
  end
  it "should be able to set italics" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "italic", :styles => [:italic] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    fonts = contents.font_settings.map { |e| e[:name] }
    fonts.should == [:Helvetica, :"Helvetica-Oblique", :Helvetica]
  end
  it "should be able to set subscript" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "subscript", :styles => [:subscript] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.font_settings[0][:size].should == 12
    contents.font_settings[1][:size].should.be.close(12 * 0.583, 0.0001)
  end
  it "should be able to set superscript" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "superscript", :styles => [:superscript] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.font_settings[0][:size].should == 12
    contents.font_settings[1][:size].should.be.close(12 * 0.583, 0.0001)
  end
  it "should be able to set compound bold and italic text" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "bold italic", :styles => [:bold, :italic] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    fonts = contents.font_settings.map { |e| e[:name] }
    fonts.should == [:Helvetica, :"Helvetica-BoldOblique", :Helvetica]
  end
  it "should be able to underline" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "underlined", :styles => [:underline] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
    line_drawing.points.length.should == 2
  end
  it "should be able to strikethrough" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "struckthrough", :styles => [:strikethrough] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
    line_drawing.points.length.should == 2
  end
  it "should be able to add URL links" do
    create_pdf
    @pdf.expects(:link_annotation).with(kind_of(Array), :Border => [0,0,0],
           :A => { :Type => :Action, :S => :URI, :URI => "http://example.com" })
    array = [{ :text => "click " },
             { :text => "here", :link => "http://example.com" },
             { :text => " to visit" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
  end
  it "should be able to add destination links" do
    create_pdf
    @pdf.expects(:link_annotation).with(kind_of(Array), :Border => [0,0,0],
                                        :Dest => "ToC")
    array = [{ :text => "Go to the " },
             { :text => "Table of Contents", :anchor => "ToC" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
  end
  it "should be able to set font size" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "sized", :size => 24 },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.font_settings[0][:size].should == 12
    contents.font_settings[1][:size].should == 24
  end
  it "should set the baseline based on the tallest fragment on a given line" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "sized", :size => 24 },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    @pdf.font_size(24) do
      text_box.height.should.be.close(@pdf.font.height, 0.001)
    end
  end
  it "should be able to set color via an rgb hex string" do
    create_pdf
    array = [{ :text => "rgb",
               :color => "ff0000" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    colors.fill_color_count.should == 3
    colors.stroke_color_count.should == 3
  end
  it "should be able to set color using a cmyk array" do
    create_pdf
    array = [{ :text => "cmyk",
               :color => [100, 0, 0, 0] }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    colors.fill_color_count.should == 3
    colors.stroke_color_count.should == 3
  end
end

describe "Text::Formatted::Box with text than can fit in the box" do
  before(:each) do
    create_pdf
    @text = "Oh hai text rect. " * 10
    @format_array = [:text => @text]
    @options = {
      :width => 162.0,
      :height => 162.0,
      :document => @pdf
    }
  end
  
  it "printed text should match requested text, except for trailing or" +
     " leading white space and that spaces may be replaced by newlines" do
    text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    text_box.render
    text_box.text.gsub("\n", " ").should == @text.strip
  end
  
  it "render should return an empty array because no text remains unprinted" do
    text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    text_box.render.should == []
  end

  it "should be truncated when the leading is set high enough to prevent all" +
     " the lines from being printed" do
    @options[:leading] = 40
    text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    text_box.render
    text_box.text.gsub("\n", " ").should.not == @text.strip
  end
end

describe "Text::Formatted::Box printing UTF-8 string with higher bit characters with" +
         " inline styling" do
  before(:each) do
    create_pdf    
    @text = "©"
    format_array = [:text => @text]
    # not enough height to print any text, so we can directly compare against
    # the input string
    bounding_height = 1.0
    options = {
      :height => bounding_height,
      :document => @pdf
    }
    @text_box = Prawn::Text::Formatted::Box.new(format_array, options)
  end
  describe "when using a TTF font" do
    before(:each) do
      file = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
      @pdf.font_families["Action Man"] = {
        :normal      => { :file => file, :font => "ActionMan" },
        :italic      => { :file => file, :font => "ActionMan-Italic" },
        :bold        => { :file => file, :font => "ActionMan-Bold" },
        :bold_italic => { :file => file, :font => "ActionMan-BoldItalic" }
      }
    end
    it "unprinted text should be in UTF-8 encoding" do
      @pdf.font("Action Man")
      remaining_text = @text_box.render
      remaining_text.first[:text].should == @text
    end
    it "subsequent calls to Text::Formatted::Box need not include the" +
       " :skip_encoding => true option" do
      @pdf.font("Action Man")
      remaining_text = @text_box.render
      lambda {
        @pdf.formatted_text_box(remaining_text, :document => @pdf)
      }.should.not.raise(ArgumentError)
    end
  end
  describe "when using an AFM font" do
    it "unprinted text should be in WinAnsi encoding" do
      remaining_text = @text_box.render
      remaining_text.first[:text].should == @pdf.font.normalize_encoding(@text)
    end
    it "subsequent calls to Text::Formatted::Box must include the" +
       " :skip_encoding => true option" do
      remaining_text = @text_box.render
      lambda {
        @pdf.formatted_text_box(remaining_text, :document => @pdf)
      }.should.raise(ArgumentError)
      lambda {
        @pdf.formatted_text_box(remaining_text, :document => @pdf,
                                :skip_encoding => true)
      }.should.not.raise(ArgumentError)
    end
  end
end
          

describe "Text::Formatted::Box with more text than can fit in the box" do
  before(:each) do
    create_pdf    
    @text = "Oh hai text rect. " * 30
    @format_array = [:text => @text]
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
      @text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    end
    it "should be truncated" do
      @text_box.render
      @text_box.text.gsub("\n", " ").should.not == @text.strip
    end
    it "render should not return an empty string because some text remains" +
      " unprinted" do
      @text_box.render.should.not == ""
    end
    it "#height should be no taller than the specified height" do
      @text_box.render
      @text_box.height.should.be <= @bounding_height
    end
    it "#height should be within one font height of the specified height" do
      @text_box.render
      @text_box.height.should.be.close(@bounding_height, @pdf.font.height)
    end
  end
  
  context "ellipses overflow" do
    it "should raise NotImplementedError" do
      @options[:overflow] = :ellipses
      lambda {
        Prawn::Text::Formatted::Box.new(@format_array, @options)
      }.should.raise(NotImplementedError)
    end
  end

  context "expand overflow" do
    before(:each) do
      @options[:overflow] = :expand
      @text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    end
    it "height should expand to encompass all the text (but not exceed the" +
      "height of the page)" do
      @text_box.render
      @text_box.height.should > @bounding_height
    end
    it "should display the entire string (as long as there was space" +
      " remaining on the page to print all the text)" do
      @text_box.render
      @text_box.text.gsub("\n", " ").should == @text.strip
    end
    it "render should return an empty array because no text remains" +
      " unprinted(as long as there was space remaining on the page to" +
      " print all the text)" do
      @text_box.render.should == []
    end
  end

  context "shrink_to_fit overflow" do
    before(:each) do
      @options[:overflow] = :shrink_to_fit
      @options[:min_font_size] = 2
      @text_box = Prawn::Text::Formatted::Box.new(@format_array, @options)
    end
    it "should display the entire text" do
      @text_box.render
      @text_box.text.gsub("\n", " ").should == @text.strip
    end
    it "render should return an empty array because no text" +
      " remains unprinted" do
      @text_box.render.should == []
    end
  end
end

describe "Text::Formatted::Box wrapping" do
  before(:each) do
    create_pdf
  end

  it "should wrap text" do
    text = "Please wrap this text about HERE. More text that should be wrapped"
    format_array = [:text => text]
    expect = "Please wrap this text about\nHERE. " +
      "More text that should be\nwrapped"

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 220,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect end of line when wrapping text" do
    text = "Please wrap only before\nTHIS word. Don't wrap this"
    format_array = [:text => text]
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 220,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect multiple newlines when wrapping text" do
    text = "Please wrap only before THIS\n\nword. Don't wrap this"
    format_array = [:text => text]
    expect= "Please wrap only before\nTHIS\n\nword. Don't wrap this"

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 200,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect multiple newlines when wrapping text when those newlines" +
    " coincide with a line break" do
    text = "Please wrap only before\n\nTHIS word. Don't wrap this"
    format_array = [:text => text]
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 220,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should respect initial newlines" do
    text = "\nThis should be on line 2"
    format_array = [:text => text]
    expect = text

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 220,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should wrap lines comprised of a single word of the bounds when" +
    " wrapping text" do
    text = "You_can_wrap_this_text_HERE"
    format_array = [:text => text]
    expect = "You_can_wrap_this_text_HE\nRE"

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array,
                                             :width    => 180,
                                             :overflow => :expand,
                                             :document => @pdf)
    text_box.render
    text_box.text.should == expect
  end

  it "should wrap lines comprised of a single word of the bounds when" +
    " wrapping text" do
    text = "©" * 30
    format_array = [:text => text]

    @pdf.font "Courier"
    text_box = Prawn::Text::Formatted::Box.new(format_array, :width => 180,
                                             :overflow => :expand,
                                             :document => @pdf)

    text_box.render

    expected = "©" * 25 + "\n" + "©" * 5
    @pdf.font.normalize_encoding!(expected)

    text_box.text.should == expected
  end

  it "should wrap non-unicode strings using single-byte word-wrapping" do
    text = "continúa esforzandote " * 5
    format_array = [:text => text]
    text_box = Prawn::Text::Formatted::Box.new(format_array, :width => 180,
                                             :document => @pdf)
    text_box.render
    results_with_accent = text_box.text

    text = "continua esforzandote " * 5
    format_array = [:text => text]
    text_box = Prawn::Text::Formatted::Box.new(format_array, :width => 180,
                                             :document => @pdf)
    text_box.render
    no_accent = text_box.text

    results_with_accent.first_line.length.should == no_accent.first_line.length
  end
  
end

def reduce_precision(float)
  ("%.5f" % float).to_f
end

class TestFragmentCallback
  def draw_border(fragment)
  end

  def draw_border_with_args(fragment, string, times)
  end
end

module TestFormattedWrapOverride
  def wrap(string)
    @text = nil
    @line_height = @document.font.height
    @descender   = @document.font.descender
    @ascender    = @document.font.ascender
    @baseline_y  = -@ascender
    draw_line("all your base are belong to us")
    []
  end
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
