# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Formatted::Box wrapping" do
  before(:each) do
    create_pdf
  end

  it "should not wrap between two fragments" do
    texts = [
      { :text => "Hello " },
      { :text => "World" },
      { :text => "2", :styles => [:superscript] }
    ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
    text_box.render
    expect(text_box.text).to eq("Hello\nWorld2")
  end

  it "should not raise an Encoding::CompatibilityError when keeping a TTF and an AFM font together" do
    file = "#{Prawn::DATADIR}/fonts/gkai00mp.ttf"

    @pdf.font_families["Kai"] = {
      :normal => { :file => file, :font => "Kai" }
    }

    texts = [
      { :text => "Hello " },
      { :text => "再见", :font => "Kai" },
      { :text => "World" }
    ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))

    text_box.render
  end

  it "should wrap between two fragments when the preceding fragment ends with white space" do
    texts = [
      { :text => "Hello " },
      { :text => "World " },
      { :text => "2", :styles => [:superscript] }
    ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
    text_box.render
    expect(text_box.text).to eq("Hello World\n2")

    texts = [
      { :text => "Hello " },
      { :text => "World\n" },
      { :text => "2", :styles => [:superscript] }
    ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
    text_box.render
    expect(text_box.text).to eq("Hello World\n2")
  end

  it "should wrap between two fragments when the final fragment begins with white space" do
    texts = [
      { :text => "Hello " },
      { :text => "World" },
      { :text => " 2", :styles => [:superscript] }
    ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
    text_box.render
    expect(text_box.text).to eq("Hello World\n2")

    texts = [
      { :text => "Hello " },
      { :text => "World" },
      { :text => "\n2", :styles => [:superscript] }
    ]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Hello World"))
    text_box.render
    expect(text_box.text).to eq("Hello World\n2")
  end

  it "should properly handle empty slices using default encoding" do
    texts = [{ :text => "Noua Delineatio Geographica generalis | Apostolicarum peregrinationum | S FRANCISCI XAUERII | Indiarum & Iaponiæ Apostoli", :font => 'Courier', :size => 10 }]
    text_box = Prawn::Text::Formatted::Box.new(texts, :document => @pdf, :width => @pdf.width_of("Noua Delineatio Geographica gen"))
    expect {
      text_box.render
    }.not_to raise_error
    expect(text_box.text).to eq("Noua Delineatio Geographica\ngeneralis | Apostolicarum\nperegrinationum | S FRANCISCI\nXAUERII | Indiarum & Iaponi\346\nApostoli")
  end
end

describe "Text::Formatted::Box with :fallback_fonts option that includes" \
  "a Chinese font and set of Chinese glyphs not in the current font" do
  it "should change the font to the Chinese font for the Chinese glyphs" do
    create_pdf
    file = "#{Prawn::DATADIR}/fonts/gkai00mp.ttf"
    @pdf.font_families["Kai"] = {
      :normal => { :file => file, :font => "Kai" }
    }
    formatted_text = [{ :text => "hello你好" },
                      { :text => "再见goodbye" }]
    @pdf.formatted_text_box(formatted_text, :fallback_fonts => ["Kai"])

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    expect(fonts_used.length).to eq(4)
    expect(fonts_used[0]).to eq(:Helvetica)
    expect(fonts_used[1].to_s).to match(/GBZenKai-Medium/)
    expect(fonts_used[2].to_s).to match(/GBZenKai-Medium/)
    expect(fonts_used[3]).to eq(:Helvetica)

    expect(text.strings[0]).to eq("hello")
    expect(text.strings[1]).to eq("你好")
    expect(text.strings[2]).to eq("再见")
    expect(text.strings[3]).to eq("goodbye")
  end
end

describe "Text::Formatted::Box with :fallback_fonts option that includes" \
  "an AFM font and Win-Ansi glyph not in the current Chinese font" do
  it "should change the font to the AFM font for the Win-Ansi glyph" do
    create_pdf
    file = "#{Prawn::DATADIR}/fonts/gkai00mp.ttf"
    @pdf.font_families["Kai"] = {
      :normal => { :file => file, :font => "Kai" }
    }
    @pdf.font("Kai")
    formatted_text = [{ :text => "hello你好" },
                      { :text => "再见€" }]
    @pdf.formatted_text_box(formatted_text, :fallback_fonts => ["Helvetica"])

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    expect(fonts_used.length).to eq(4)
    expect(fonts_used[0].to_s).to match(/GBZenKai-Medium/)
    expect(fonts_used[1].to_s).to match(/GBZenKai-Medium/)
    expect(fonts_used[2].to_s).to match(/GBZenKai-Medium/)
    expect(fonts_used[3]).to eq(:Helvetica)

    expect(text.strings[0]).to eq("hello")
    expect(text.strings[1]).to eq("你好")
    expect(text.strings[2]).to eq("再见")
    expect(text.strings[3]).to eq("€")
  end
end

describe "Text::Formatted::Box with :fallback_fonts option and fragment " \
  "level font" do
  it "should use the fragment level font except for glyphs not in that font" do
    create_pdf
    file = "#{Prawn::DATADIR}/fonts/gkai00mp.ttf"
    @pdf.font_families["Kai"] = {
      :normal => { :file => file, :font => "Kai" }
    }

    file = "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
    @pdf.font_families["DejaVu Sans"] = {
      :normal => { :file => file }
    }

    formatted_text = [{ :text => "hello你好" },
                      { :text => "再见goodbye", :font => "Times-Roman" }]
    @pdf.formatted_text_box(formatted_text, :fallback_fonts => ["Kai"])

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    expect(fonts_used.length).to eq(4)
    expect(fonts_used[0]).to eq(:Helvetica)
    expect(fonts_used[1].to_s).to match(/GBZenKai-Medium/)
    expect(fonts_used[2].to_s).to match(/GBZenKai-Medium/)
    expect(fonts_used[3]).to eq(:"Times-Roman")

    expect(text.strings[0]).to eq("hello")
    expect(text.strings[1]).to eq("你好")
    expect(text.strings[2]).to eq("再见")
    expect(text.strings[3]).to eq("goodbye")
  end
end

describe "Text::Formatted::Box" do
  before(:each) do
    create_pdf
    file = "#{Prawn::DATADIR}/fonts/gkai00mp.ttf"
    @pdf.font_families["Kai"] = {
      :normal => { :file => file, :font => "Kai" }
    }

    file = "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
    @pdf.font_families["DejaVu Sans"] = {
      :normal => { :file => file }
    }

    @formatted_text = [{ :text => "hello你好" }]
    @pdf.fallback_fonts(["Kai"])
    @pdf.fallback_fonts = ["Kai"]
  end
  it "#fallback_fonts should return the document-wide fallback fonts" do
    expect(@pdf.fallback_fonts).to eq(["Kai"])
  end
  it "should be able to set text fallback_fonts document-wide" do
    @pdf.formatted_text_box(@formatted_text)

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    expect(fonts_used.length).to eq(2)
    expect(fonts_used[0]).to eq(:Helvetica)
    expect(fonts_used[1].to_s).to match(/GBZenKai-Medium/)
  end
  it "should be able to override document-wide fallback_fonts" do
    @pdf.fallback_fonts = ["DejaVu Sans"]
    @pdf.formatted_text_box(@formatted_text, :fallback_fonts => ["Kai"])

    text = PDF::Inspector::Text.analyze(@pdf.render)

    fonts_used = text.font_settings.map { |e| e[:name] }
    expect(fonts_used.length).to eq(2)
    expect(fonts_used[0]).to eq(:Helvetica)
    expect(fonts_used[1]).to match(/Kai/)
  end
  it "should omit the fallback fonts overhead when passing an empty array " \
    "as the :fallback_fonts" do
    @pdf.font("Kai")

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

    @pdf.font("Kai")

    box.expects(:process_fallback_fonts).never
    box.render
  end
end

describe "Text::Formatted::Box with :fallback_fonts option " \
  "with glyphs not in the primary or the fallback fonts" do
  it "should raise an exception" do
    file = "#{Prawn::DATADIR}/fonts/gkai00mp.ttf"
    create_pdf
    formatted_text = [{ :text => "hello world. 世界你好。" }]

    expect {
      @pdf.formatted_text_box(formatted_text, :fallback_fonts => ["Courier"])
    }.to raise_error(Prawn::Errors::IncompatibleStringEncoding)
  end
end

describe "Text::Formatted::Box#extensions" do
  it "should be able to override default line wrapping" do
    create_pdf
    Prawn::Text::Formatted::Box.extensions << TestFormattedWrapOverride
    @pdf.formatted_text_box([{ :text => "hello world" }], {})
    Prawn::Text::Formatted::Box.extensions.delete(TestFormattedWrapOverride)
    text = PDF::Inspector::Text.analyze(@pdf.render)
    expect(text.strings[0]).to eq("all your base are belong to us")
  end
  it "overriding Text::Formatted::Box line wrapping should not affect " \
     "Text::Box wrapping" do
    create_pdf
    Prawn::Text::Formatted::Box.extensions << TestFormattedWrapOverride
    @pdf.text_box("hello world", {})
    Prawn::Text::Formatted::Box.extensions.delete(TestFormattedWrapOverride)
    text = PDF::Inspector::Text.analyze(@pdf.render)
    expect(text.strings[0]).to eq("hello world")
  end
  it "overriding Text::Box line wrapping should override Text::Box wrapping" do
    create_pdf
    Prawn::Text::Box.extensions << TestFormattedWrapOverride
    @pdf.text_box("hello world", {})
    Prawn::Text::Box.extensions.delete(TestFormattedWrapOverride)
    text = PDF::Inspector::Text.analyze(@pdf.render)
    expect(text.strings[0]).to eq("all your base are belong to us")
  end
end

describe "Text::Formatted::Box#render" do
  it "should handle newlines" do
    create_pdf
    array = [{ :text => "hello\nworld" }]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    expect(text_box.text).to eq("hello\nworld")
  end
  it "should omit spaces from the beginning of the line" do
    create_pdf
    array = [{ :text => " hello\n world" }]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    expect(text_box.text).to eq("hello\nworld")
  end
  it "should be okay printing a line of whitespace" do
    create_pdf
    array = [{ :text => "hello\n    \nworld" }]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    expect(text_box.text).to eq("hello\n\nworld")

    array = [{ :text => "hello" + " " * 500 },
             { :text => " " * 500 },
             { :text => " " * 500 + "\n" },
             { :text => "world" }]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    expect(text_box.text).to eq("hello\n\nworld")
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
    expect(text.strings[0]).to eq("era woh ,")
    expect(text.strings[1]).to eq("world")
    expect(text.strings[2]).to eq(" olleh" * number_of_hellos)
    expect(text.strings[3]).to eq("?uoy")
  end
end

describe "Text::Formatted::Box#render" do
  it "should be able to perform fragment callbacks" do
    create_pdf
    callback_object = TestFragmentCallback.new("something", 7, :document => @pdf)
    callback_object.expects(:render_behind).with(
      kind_of(Prawn::Text::Formatted::Fragment)
    )
    callback_object.expects(:render_in_front).with(
      kind_of(Prawn::Text::Formatted::Fragment)
    )
    array = [{ :text => "hello world " },
             { :text => "callback now",
               :callback => callback_object }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
  end
  it "should be able to perform fragment callbacks on multiple objects" do
    create_pdf

    callback_object = TestFragmentCallback.new("something", 7, :document => @pdf)
    callback_object.expects(:render_behind).with(
      kind_of(Prawn::Text::Formatted::Fragment)
    )
    callback_object.expects(:render_in_front).with(
      kind_of(Prawn::Text::Formatted::Fragment)
    )

    callback_object2 = TestFragmentCallback.new("something else", 14, :document => @pdf)
    callback_object2.expects(:render_behind).with(
      kind_of(Prawn::Text::Formatted::Fragment)
    )
    callback_object2.expects(:render_in_front).with(
      kind_of(Prawn::Text::Formatted::Fragment)
    )

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

    text_box.render # trigger callbacks
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
    expect(fonts).to eq([:Helvetica, :"Times-Bold", :Helvetica])
    expect(contents.strings[0]).to eq("this contains ")
    expect(contents.strings[1]).to eq("Times-Bold")
    expect(contents.strings[2]).to eq(" text")
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
    expect(fonts).to eq([:Helvetica, :"Helvetica-Bold", :Helvetica])
    expect(contents.strings[0]).to eq("this contains ")
    expect(contents.strings[1]).to eq("bold")
    expect(contents.strings[2]).to eq(" text")
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
    expect(fonts).to eq([:Helvetica, :"Helvetica-Oblique", :Helvetica])
  end
  it "should be able to set subscript" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "subscript", :size => 18, :styles => [:subscript] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.font_settings[0][:size]).to eq(12)
    expect(contents.font_settings[1][:size]).to be_within(0.0001).of(18 * 0.583)
  end
  it "should be able to set superscript" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "superscript", :size => 18, :styles => [:superscript] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    contents = PDF::Inspector::Text.analyze(@pdf.render)
    expect(contents.font_settings[0][:size]).to eq(12)
    expect(contents.font_settings[1][:size]).to be_within(0.0001).of(18 * 0.583)
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
    expect(fonts).to eq([:Helvetica, :"Helvetica-BoldOblique", :Helvetica])
  end
  it "should be able to underline" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "underlined", :styles => [:underline] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
    expect(line_drawing.points.length).to eq(2)
  end
  it "should be able to strikethrough" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "struckthrough", :styles => [:strikethrough] },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
    expect(line_drawing.points.length).to eq(2)
  end
  it "should be able to add URL links" do
    create_pdf
    @pdf.expects(:link_annotation).with(kind_of(Array), :Border => [0, 0, 0],
                                                        :A => {
                                                          :Type => :Action,
                                                          :S => :URI,
                                                          :URI => "http://example.com"
                                                        })
    array = [{ :text => "click " },
             { :text => "here", :link => "http://example.com" },
             { :text => " to visit" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
  end
  it "should be able to add destination links" do
    create_pdf
    @pdf.expects(:link_annotation).with(kind_of(Array), :Border => [0, 0, 0],
                                                        :Dest => "ToC")
    array = [{ :text => "Go to the " },
             { :text => "Table of Contents", :anchor => "ToC" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
  end
  it "should be able to add local actions" do
    create_pdf
    @pdf.expects(:link_annotation).with(kind_of(Array), :Border => [0, 0, 0],
                                                        :A => {
                                                          :Type => :Action,
                                                          :S => :Launch,
                                                          :F => "../example.pdf",
                                                          :NewWindow => true
                                                        })
    array = [{ :text => "click " },
             { :text => "here", :local => "../example.pdf" },
             { :text => " to open a local file" }]
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
    expect(contents.font_settings[0][:size]).to eq(12)
    expect(contents.font_settings[1][:size]).to eq(24)
  end
  it "should set the baseline based on the tallest fragment on a given line" do
    create_pdf
    array = [{ :text => "this contains " },
             { :text => "sized", :size => 24 },
             { :text => " text" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    @pdf.font_size(24) do
      expect(text_box.height).to be_within(0.001).of(@pdf.font.ascender + @pdf.font.descender)
    end
  end
  it "should be able to set color via an rgb hex string" do
    create_pdf
    array = [{ :text => "rgb",
               :color => "ff0000" }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    expect(colors.fill_color_count).to eq(2)
    expect(colors.stroke_color_count).to eq(2)
  end
  it "should be able to set color using a cmyk array" do
    create_pdf
    array = [{ :text => "cmyk",
               :color => [100, 0, 0, 0] }]
    text_box = Prawn::Text::Formatted::Box.new(array, :document => @pdf)
    text_box.render
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    expect(colors.fill_color_count).to eq(2)
    expect(colors.stroke_color_count).to eq(2)
  end
end

describe "Text::Formatted::Box#render(:dry_run => true)" do
  it "should not change the graphics state of the document" do
    create_pdf

    state_before = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    fill_color_count = state_before.fill_color_count
    stroke_color_count = state_before.stroke_color_count
    stroke_color_space_count = state_before.stroke_color_space_count

    array = [{ :text => 'Foo',
               :color => [0, 0, 0, 100] }]
    options = { :document => @pdf }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render(:dry_run => true)

    state_after = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    expect(state_after.fill_color_count).to eq(fill_color_count)
    expect(state_after.stroke_color_count).to eq(stroke_color_count)
    expect(state_after.stroke_color_space_count).to eq(stroke_color_space_count)
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
    expect(contents.character_spacing[0]).to eq(7)
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
    expect(text_box.text).to eq("hello\nworld")
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
    expect(contents.word_spacing).to be_empty
  end
end

describe "Text::Formatted::Box#render with :valign => :center" do
  it "should have a bottom gap equal to baseline and bottom of box" do
    create_pdf
    box_height = 100
    y = 450
    array = [{ :text => 'Vertical Align' }]
    options = {
      :document => @pdf,
      :valign => :center,
      :at => [0, y],
      :width => 100,
      :height => box_height,
      :size => 16
    }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    line_padding = (box_height - text_box.height + text_box.descender) * 0.5
    baseline = y - line_padding

    expect(text_box.at[1]).to be_within(0.01).of(baseline)
  end
end

describe "Text::Formatted::Box#render with :valign => :bottom" do
  it "should not render a gap between the text and bottom of box" do
    create_pdf
    box_height = 100
    y = 450
    array = [{ :text => 'Vertical Align' }]
    options = {
      :document => @pdf,
      :valign => :bottom,
      :at => [0, y],
      :width => 100,
      :height => box_height,
      :size => 16
    }
    text_box = Prawn::Text::Formatted::Box.new(array, options)
    text_box.render
    top_padding = y - (box_height - text_box.height)

    expect(text_box.at[1]).to be_within(0.01).of(top_padding)
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
