# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

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
