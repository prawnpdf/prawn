# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Formatted::Box wrapping" do
  before(:each) do
    create_pdf
  end

  it "should not wrap between two fragments" do
    texts = [
      {:text => "Hello "},
      {:text => "World"},
      {:text => "2", :styles => [:superscript]},
      ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
    text_box.render
    text_box.text.should == "Hello\nWorld2"
  end

  it "should not raise Encoding::CompatibilityError when keeping a TTF and an " +
    "AFM font together" do
    ruby_19 do
      file = "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
      @pdf.font_families["Kai"] = {
        :normal => { :file => file, :font => "Kai" }
      }

      texts = [{ :text => "Hello " },
               { :text => "再见", :font => "Kai"},
               { :text => "World" }]
      text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
      lambda {
        text_box.render
      }.should.not.raise(Encoding::CompatibilityError)
    end
  end

  it "should wrap between two fragments when the preceding fragment ends with white space" do
    texts = [
      {:text => "Hello "},
      {:text => "World "},
      {:text => "2", :styles => [:superscript]},
      ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
    text_box.render
    text_box.text.should == "Hello World\n2"

    texts = [
      {:text => "Hello "},
      {:text => "World\n"},
      {:text => "2", :styles => [:superscript]},
      ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
    text_box.render
    text_box.text.should == "Hello World\n2"
  end

  it "should wrap between two fragments when the final fragment begins with white space" do
    texts = [
      {:text => "Hello "},
      {:text => "World"},
      {:text => " 2", :styles => [:superscript]},
      ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
    text_box.render
    text_box.text.should == "Hello World\n2"

    texts = [
      {:text => "Hello "},
      {:text => "World"},
      {:text => "\n2", :styles => [:superscript]},
      ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
    text_box.render
    text_box.text.should == "Hello World\n2"
  end

  it "should properly handle empty slices using default encoding" do
    texts = [{ :text => "Noua Delineatio Geographica generalis | Apostolicarum peregrinationum | S FRANCISCI XAUERII | Indiarum & Iaponiæ Apostoli", :font => 'Courier', :size => 10 }]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Noua Delineatio Geographica gen"))
    assert_nothing_raised do
      text_box.render
    end
    text_box.text.should == "Noua Delineatio Geographica\ngeneralis | Apostolicarum\nperegrinationum | S FRANCISCI\nXAUERII | Indiarum & Iaponi\346\nApostoli"
  end
  
  describe "Unicode" do
    before do
      if RUBY_VERSION < '1.9'
        @reset_value = $KCODE
        $KCODE='u'
      else
        @reset_value = [Encoding.default_external, Encoding.default_internal]
        Encoding.default_external = Encoding::UTF_8
        Encoding.default_internal = Encoding::UTF_8
      end
    end
    
    after do
      if RUBY_VERSION < '1.9'
        $KCODE=@reset_value
      else
        Encoding.default_external = @reset_value[0]
        Encoding.default_internal = @reset_value[1]
      end
    end

    it "should properly handle empty slices using Unicode encoding" do
      texts = [{ :text => "Noua Delineatio Geographica generalis | Apostolicarum peregrinationum | S FRANCISCI XAUERII | Indiarum & Iaponiæ Apostoli", :font => 'Courier', :size => 10 }]
      text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Noua Delineatio Geographica gen"))
      assert_nothing_raised do
        text_box.render
      end
      text_box.text.should == "Noua Delineatio Geographica\ngeneralis | Apostolicarum\nperegrinationum | S FRANCISCI\nXAUERII | Indiarum & Iaponi\346\nApostoli"
    end
  end
end

describe "Text::Formatted::Box with :fallback_fonts option that includes" +
  "a Chinese font and set of Chinese glyphs not in the current font" do
  it "should change the font to the Chinese font for the Chinese glyphs" do
    create_pdf
    file = "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
    @pdf.font_families["Kai"] = {
      :normal => { :file => file, :font => "Kai" }
    }
    formatted_text = [{ :text => "hello你好" },
                      { :text => "再见goodbye" }]
    @pdf.formatted_text_box(formatted_text, :fallback_fonts => ["Kai"])

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    fonts_used.length.should == 4
    fonts_used[0].should == :"Helvetica"
    fonts_used[1].to_s.should =~ /GBZenKai-Medium/
    fonts_used[2].to_s.should =~ /GBZenKai-Medium/
    fonts_used[3].should == :"Helvetica"

    text.strings[0].should == "hello"
    text.strings[1].should == "你好"
    text.strings[2].should == "再见"
    text.strings[3].should == "goodbye"
  end
end

describe "Text::Formatted::Box with :fallback_fonts option that includes" +
  "an AFM font and Win-Ansi glyph not in the current Chinese font" do
  it "should change the font to the AFM font for the Win-Ansi glyph" do
    create_pdf
    file = "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
    @pdf.font_families["Kai"] = {
      :normal => { :file => file, :font => "Kai" }
    }
    @pdf.font("Kai")
    formatted_text = [{ :text => "hello你好" },
                      { :text => "再见€" }]
    @pdf.formatted_text_box(formatted_text, :fallback_fonts => ["Helvetica"])

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    fonts_used.length.should == 4
    fonts_used[0].to_s.should =~ /GBZenKai-Medium/
    fonts_used[1].to_s.should =~ /GBZenKai-Medium/
    fonts_used[2].to_s.should =~ /GBZenKai-Medium/
    fonts_used[3].should == :"Helvetica"

    text.strings[0].should == "hello"
    text.strings[1].should == "你好"
    text.strings[2].should == "再见"
    text.strings[3].should == "€"
  end
end

describe "Text::Formatted::Box with :fallback_fonts option and fragment " +
  "level font" do
  it "should use the fragment level font except for glyphs not in that font" do
    create_pdf
    file = "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
    @pdf.font_families["Kai"] = {
      :normal => { :file => file, :font => "Kai" }
    }
    formatted_text = [{ :text => "hello你好" },
                      { :text => "再见goodbye", :font => "Times-Roman" }]
    @pdf.formatted_text_box(formatted_text, :fallback_fonts => ["Kai"])

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    fonts_used.length.should == 4
    fonts_used[0].should == :"Helvetica"
    fonts_used[1].to_s.should =~ /GBZenKai-Medium/
    fonts_used[2].to_s.should =~ /GBZenKai-Medium/
    fonts_used[3].should == :"Times-Roman"

    text.strings[0].should == "hello"
    text.strings[1].should == "你好"
    text.strings[2].should == "再见"
    text.strings[3].should == "goodbye"
  end
end

describe "Text::Formatted::Box" do
  before(:each) do
    create_pdf
    file = "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
    @pdf.font_families["Kai"] = {
      :normal => { :file => file, :font => "Kai" }
    }
    @formatted_text = [{ :text => "hello你好" }]
    @pdf.fallback_fonts(["Kai"])
    @pdf.fallback_fonts = ["Kai"]
  end
  it "#fallback_fonts should return the document-wide fallback fonts" do
    @pdf.fallback_fonts.should == ["Kai"]
  end
  it "should be able to set text fallback_fonts document-wide" do
    @pdf.formatted_text_box(@formatted_text)

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    fonts_used.length.should == 2
    fonts_used[0].should == :"Helvetica"
    fonts_used[1].to_s.should =~ /GBZenKai-Medium/
  end
  it "should be able to override document-wide fallback_fonts" do
    @pdf.formatted_text_box(@formatted_text, :fallback_fonts => ["Courier"])

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    fonts_used.length.should == 1
    fonts_used[0].should == :"Helvetica"
  end
  it "should omit the fallback fonts overhead when passing an empty array " +
    "as the :fallback_fonts" do
    box = Prawn::Text::Formatted::Box.new(@formatted_text,
                                          :document => @pdf,
                                          :fallback_fonts => [])
    box.expects(:process_fallback_fonts).never
    box.render
  end
  it "should be able to clear document-wide fallback_fonts" do
    @pdf.fallback_fonts([])
    box = Prawn::Text::Formatted::Box.new(@formatted_text,
                                          :document => @pdf)
    box.expects(:process_fallback_fonts).never
    box.render
  end
end

describe "Text::Formatted::Box with :fallback_fonts option " +
  "with glyphs not in the primary or the fallback fonts" do
  it "should use the primary font" do
    create_pdf
    formatted_text = [{ :text => "hello world. 世界你好。" }]
    @pdf.formatted_text_box(formatted_text, :fallback_fonts => ["Helvetica"])

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    fonts_used.length.should == 1
    fonts_used[0].should == :"Helvetica"
  end
end

describe "Text::Formatted::Box#extensions" do
  it "should be able to override default line wrapping" do
    create_pdf
    Prawn::Text::Formatted::Box.extensions << TestFormattedWrapOverride
    @pdf.formatted_text_box([{ :text => "hello world" }], {})
    Prawn::Text::Formatted::Box.extensions.delete(TestFormattedWrapOverride)
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[0].should == "all your base are belong to us"
  end
  it "overriding Text::Formatted::Box line wrapping should not affect " +
     "Text::Box wrapping" do
    create_pdf
    Prawn::Text::Formatted::Box.extensions << TestFormattedWrapOverride
    @pdf.text_box("hello world", {})
    Prawn::Text::Formatted::Box.extensions.delete(TestFormattedWrapOverride)
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[0].should == "hello world"
  end
  it "overriding Text::Box line wrapping should override Text::Box wrapping" do
    create_pdf
    Prawn::Text::Box.extensions << TestFormattedWrapOverride
    @pdf.text_box("hello world", {})
    Prawn::Text::Box.extensions.delete(TestFormattedWrapOverride)
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[0].should == "all your base are belong to us"
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
  it "should be okay printing a line of whitespace" do
    create_pdf
    array = [{ :text => "hello\n    \nworld"}]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text_box.text.should == "hello\n\nworld"


    array = [{ :text => "hello" + " " * 500},
             { :text => " " * 500 },
             { :text => " " * 500 + "\n"},
             { :text => "world"}]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text_box.text.should == "hello\n\nworld"
  end
  it "should enable fragment level direction setting" do
    create_pdf
    number_of_hellos = 18
    array = [
             { :text => "hello " * number_of_hellos },
             { :text => "world", :direction => :ltr },
             { :text => ", how are you?" }
            ]
    options = { :document => @pdf, :direction => :rtl }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[0].should == "era woh ,"
    text.strings[1].should == "world"
    text.strings[2].should == " olleh" * number_of_hellos
    text.strings[3].should == "?uoy"
  end
end

describe "Text::Formatted::Box#render" do
  it "should be able to perform fragment callbacks" do
    create_pdf
    callback_object = TestFragmentCallback.new("something", 7,
                                               :document => @pdf)
    callback_object.expects(:render_behind).with(
                                      kind_of(Prawn::Text::Formatted::Fragment))
    callback_object.expects(:render_in_front).with(
                                      kind_of(Prawn::Text::Formatted::Fragment))
    array = [{ :text => "hello world " },
             { :text => "callback now",
               :callback => callback_object }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
  end
  it "should be able to perform fragment callbacks on multiple objects" do
    create_pdf

    callback_object = TestFragmentCallback.new("something", 7,
                                               :document => @pdf)
    callback_object.expects(:render_behind).with(
                                      kind_of(Prawn::Text::Formatted::Fragment))
    callback_object.expects(:render_in_front).with(
                                      kind_of(Prawn::Text::Formatted::Fragment))

    callback_object2 = TestFragmentCallback.new("something else", 14,
                                               :document => @pdf)
    callback_object2.expects(:render_behind).with(
                                      kind_of(Prawn::Text::Formatted::Fragment))
    callback_object2.expects(:render_in_front).with(
                                      kind_of(Prawn::Text::Formatted::Fragment))

    array = [{ :text => "hello world " },
             { :text => "callback now",
               :callback => [callback_object, callback_object2] }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
  end
  it "fragment callbacks should be able to define only the callback they need" do
    create_pdf
    behind = TestFragmentCallbackBehind.new("something", 7,
                                            :document => @pdf)
    in_front = TestFragmentCallbackInFront.new("something", 7,
                                               :document => @pdf)
    array = [{ :text => "hello world " },
             { :text => "callback now",
               :callback => [behind, in_front] }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    lambda { text_box.render }.should.not.raise(NoMethodError)
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
             { :text => "subscript", :size => 18, :styles => [:subscript] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.font_settings[0][:size].should == 12
    contents.font_settings[1][:size].should.be.close(18 * 0.583, 0.0001)
  end
  it "should be able to set superscript" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "superscript", :size => 18, :styles => [:superscript] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.font_settings[0][:size].should == 12
    contents.font_settings[1][:size].should.be.close(18 * 0.583, 0.0001)
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
      text_box.height.should.be.close(@pdf.font.ascender + @pdf.font.descender, 0.001)
    end
  end
  it "should be able to set color via an rgb hex string" do
    create_pdf
    array = [{ :text => "rgb",
               :color => "ff0000" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    colors.fill_color_count.should == 2
    colors.stroke_color_count.should == 2
  end
  it "should be able to set color using a cmyk array" do
    create_pdf
    array = [{ :text => "cmyk",
               :color => [100, 0, 0, 0] }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    colors.fill_color_count.should == 2
    colors.stroke_color_count.should == 2
  end
end

describe "Text::Formatted::Box#render with fragment level :character_spacing option" do
  it "should draw the character spacing to the document" do
    create_pdf
    array = [{ :text => "hello world",
               :character_spacing => 7 }]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.character_spacing[0].should == 7
  end
  it "should draw the character spacing to the document" do
    create_pdf
    array = [{ :text => "hello world",
               :font => "Courier",
               :character_spacing => 10 }]
    options = { :document => @pdf,
                :width => 100,
                :overflow => :expand }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    text_box.text.should == "hello\nworld"
  end
end

describe "Text::Formatted::Box#render with :align => :justify" do
  it "should not justify the last line of a paragraph" do
    create_pdf
    array = [{ :text => "hello world " },
             { :text => "\n" },
             { :text => "goodbye" }]
    options = { :document => @pdf, :align => :justify }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    contents.word_spacing.should.be.empty
  end
end

class TestFragmentCallback
  def initialize(string, number, options)
    @document = options[:document]
  end

  def render_behind(fragment)
  end

  def render_in_front(fragment)
  end
end

class TestFragmentCallbackBehind
  def initialize(string, number, options)
    @document = options[:document]
  end

  def render_behind(fragment)
  end
end

class TestFragmentCallbackInFront
  def initialize(string, number, options)
    @document = options[:document]
  end

  def render_in_front(fragment)
  end
end

module TestFormattedWrapOverride
  def wrap(array)
    initialize_wrap([{ :text => 'all your base are belong to us' }])
    line_to_print = @line_wrap.wrap_line(:document => @document,
                                         :kerning => @kerning,
                                         :width => 10000,
                                         :arranger => @arranger)
    fragment = @arranger.retrieve_fragment
    format_and_draw_fragment(fragment, 0, @line_wrap.width, 0)

    []
  end
end
