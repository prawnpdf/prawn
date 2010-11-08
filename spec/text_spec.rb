# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Prawn::Text::NBSP" do
  it "should be defined" do
    Prawn::Text::NBSP.should == " "
  end
end

describe "#height_of" do
  before(:each) { create_pdf }

  it "should return the height that would be required to print a" +
    "particular string of text" do
    original_y = @pdf.y
    @pdf.text("Foo")
    new_y = @pdf.y
    @pdf.height_of("Foo", :width => 300).should.be.close(original_y - new_y, 0.0001)
  end

  it "should raise CannotFit if a too-small width is given" do
    lambda do
      @pdf.height_of("text", :width => 1)
    end.should.raise(Prawn::Errors::CannotFit)
  end

  it "should raise NotImplementedError if :indent_paragraphs option is provided" do
    lambda {
      @pdf.height_of("hai", :width => 300,
                     :indent_paragraphs => 60)
    }.should.raise(NotImplementedError)
  end

  it "should not raise Prawn::Errors::UnknownOption if :final_gap option is provided" do
    lambda {
      @pdf.height_of("hai", :width => 300,
                     :final_gap => true)
    }.should.not.raise(Prawn::Errors::UnknownOption)
  end
end

describe "#text" do
  before(:each) { create_pdf }

  it "should not fail when @output is nil when Prawn::Core::Text::LineWrap#finalize_line is called" do
    # need a document with margins for these particulars to produce the
    # condition that was throwing the error
    pdf = Prawn::Document.new
    lambda {
      pdf.text "transparency " * 150, :size => 18
    }.should.not.raise(TypeError)
  end

  it "should allow drawing empty strings to the page" do
    @pdf.text " "
    text = PDF::Inspector::Text.analyze(@pdf.render)
    # If anything is rendered to the page, it should be whitespace.
    text.strings.each { |str| str.should =~ /\A\s*\z/ }
  end

  it "should default to use kerning information" do
    @pdf.text "hello world"
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.kerned[0].should.be true
  end

  it "should be able to disable kerning with an option" do
    @pdf.text "hello world", :kerning => false
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.kerned[0].should.be false
  end

  it "should be able to disable kerning document wide" do
    @pdf.default_kerning(false)
    @pdf.default_kerning = false
    @pdf.text "hello world"
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.kerned[0].should.be false
  end

  it "option should be able to override document wide kerning disabling" do
    @pdf.default_kerning = false
    @pdf.text "hello world", :kerning => true
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.kerned[0].should.be true
  end

  it "should raise ArgumentError if :at option included" do
    lambda { @pdf.text("hai", :at => [0, 0]) }.should.raise(ArgumentError)
  end

  it "should advance down the document based on font_height" do
    position = @pdf.y
    @pdf.text "Foo"

    @pdf.y.should.be.close(position - @pdf.font.height, 0.0001)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz"
    @pdf.y.should.be.close(position - 3*@pdf.font.height, 0.0001)
  end

  it "should advance down the document based on font_height" +
    " with size option" do
    position = @pdf.y
    @pdf.text "Foo", :size => 15

    @pdf.font_size = 15
    @pdf.y.should.be.close(position - @pdf.font.height, 0.0001)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz"
    @pdf.y.should.be.close(position - 3 * @pdf.font.height, 0.0001)
  end

  it "should advance down the document based on font_height" +
    " with leading option" do
    position = @pdf.y
    leading = 2
    @pdf.text "Foo", :leading => leading

    @pdf.y.should.be.close(position - @pdf.font.height - leading, 0.0001)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz"
    @pdf.y.should.be.close(position - 3*@pdf.font.height, 0.0001)
  end

  it "should advance down the document based on font ascender only "+
    "if final_gap is given" do
    position = @pdf.y
    @pdf.text "Foo", :final_gap => false

    @pdf.y.should.be.close(position - @pdf.font.ascender, 0.0001)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz", :final_gap => false
    @pdf.y.should.be.close(position - 2*@pdf.font.height - @pdf.font.ascender, 0.0001)
  end

  it "should be able to print text starting at the last line of a page" do
    @pdf.move_cursor_to(@pdf.font.height)
    @pdf.text("hello world")
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 1
  end

  it "should default to 12 point helvetica" do
    @pdf.text "Blah"
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:name].should == :Helvetica
    text.font_settings[0][:size].should == 12
    text.strings.first.should == "Blah"
  end

  it "should allow setting font size" do
    @pdf.text "Blah", :size => 16
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:size].should == 16
  end

  it "should allow setting a default font size" do
    @pdf.font_size = 16
    @pdf.text "Blah"
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:size].should == 16
  end

  it "should allow overriding default font for a single instance" do
    @pdf.font_size = 16

    @pdf.text "Blah", :size => 11
    @pdf.text "Blaz"
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:size].should == 11
    text.font_settings[1][:size].should == 16
  end

  it "should allow setting a font size transaction with a block" do
    @pdf.font_size 16 do
      @pdf.text 'Blah'
    end

    @pdf.text 'blah'

    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:size].should == 16
    text.font_settings[1][:size].should == 12
  end

  it "should allow manual setting the font size " +
    "when in a font size block" do
    @pdf.font_size(16) do
      @pdf.text 'Foo'
      @pdf.text 'Blah', :size => 11
      @pdf.text 'Blaz'
    end
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:size].should == 16
    text.font_settings[1][:size].should == 11
    text.font_settings[2][:size].should == 16
  end

  it "should allow registering of built-in font_settings on the fly" do
    @pdf.font "Times-Roman"
    @pdf.text "Blah"
    @pdf.font "Courier"
    @pdf.text "Blaz"
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings[0][:name].should == :"Times-Roman"
    text.font_settings[1][:name].should == :Courier
  end

  it "should utilise the same default font across multiple pages" do
    @pdf.text "Blah"
    @pdf.start_new_page
    @pdf.text "Blaz"
    text = PDF::Inspector::Text.analyze(@pdf.render)

    text.font_settings.size.should  == 2
    text.font_settings[0][:name].should == :Helvetica
    text.font_settings[1][:name].should == :Helvetica
  end

  it "should raise an exception when an unknown font is used" do
    lambda { @pdf.font "Pao bu" }.should.raise(Prawn::Errors::UnknownFont)
  end

  it "should correctly render a utf-8 string when using a built-in font" do
    str = "©" # copyright symbol
    @pdf.text str

    # grab the text from the rendered PDF and ensure it matches
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.first.should == str
  end

  it "should correctly render a utf-8 string when using a TTF font" do
    str = "©" # copyright symbol
    @pdf.font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
    @pdf.text str

    # grab the text from the rendered PDF and ensure it matches
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.first.should == str
  end

  it "should correctly render a string with higher bit characters across" +
     " a page break when using a built-in font" do
    str = "©"
    @pdf.move_cursor_to(@pdf.font.height)
    @pdf.text(str + "\n" + str)

    # grab the text from the rendered PDF and ensure it matches
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[1].should == str.strip
  end

  it "should correctly render a string with higher bit characters across" +
    " a page break when using a built-in font and :indent_paragraphs option" do
    str = "©"
    @pdf.move_cursor_to(@pdf.font.height)
    @pdf.text(str + "\n" + str, :indent_paragraphs => 20)

    # grab the text from the rendered PDF and ensure it matches
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[1].should == str.strip
  end

  if "spec".respond_to?(:encode!)
    # Handle non utf-8 string encodings in a sane way on M17N aware VMs
    it "should raise an exception when a utf-8 incompatible string is rendered" do
      str = "Blah \xDD"
      str.force_encoding("ASCII-8BIT")
      lambda { @pdf.text str }.should.raise(ArgumentError)
    end
    it "should not raise an exception when a shift-jis string is rendered" do
      datafile = "#{Prawn::BASEDIR}/data/shift_jis_text.txt"
      sjis_str = File.open(datafile, "r:shift_jis") { |f| f.gets }
      @pdf.font("#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf")
      lambda { @pdf.text sjis_str }.should.not.raise(ArgumentError)
    end
  else
    # Handle non utf-8 string encodings in a sane way on non-M17N aware VMs
    it "should raise an exception when a corrupt utf-8 string is rendered" do
      str = "Blah \xDD"
      lambda { @pdf.text str }.should.raise(ArgumentError)
    end
    it "should raise an exception when a shift-jis string is rendered" do
      sjis_str = File.read("#{Prawn::BASEDIR}/data/shift_jis_text.txt")
      lambda { @pdf.text sjis_str }.should.raise(ArgumentError)
    end
  end

  it "should call move_past_bottom when printing more text than can fit" +
     " between the current document.y and bounds.bottom" do
    @pdf.y = @pdf.font.height
    @pdf.text "Hello"
    @pdf.text "World"
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 2
    pages[0][:strings].should == ["Hello"]
    pages[1][:strings].should == ["World"]
  end

  describe "with :indent_paragraphs option" do
    it "should indent the paragraphs" do
      hello = "hello " * 50
      hello2 = "hello " * 50
      @pdf.text(hello + "\n" + hello2, :indent_paragraphs => 60)
      text = PDF::Inspector::Text.analyze(@pdf.render)
      text.strings[0].should == ("hello " * 19).strip
      text.strings[1].should == ("hello " * 21).strip
      text.strings[3].should == ("hello " * 19).strip
      text.strings[4].should == ("hello " * 21).strip
    end
    describe "when wrap to new page, and first line of new page" +
             " is not the start of a new paragraph, that line should" +
             " not be indented" do
      it "should indent the paragraphs" do
        hello = "hello " * 50
        hello2 = "hello " * 50
        @pdf.move_cursor_to(@pdf.font.height)
        @pdf.text(hello + "\n" + hello2, :indent_paragraphs => 60)
        text = PDF::Inspector::Text.analyze(@pdf.render)
        text.strings[0].should == ("hello " * 19).strip
        text.strings[1].should == ("hello " * 21).strip
        text.strings[3].should == ("hello " * 19).strip
        text.strings[4].should == ("hello " * 21).strip
      end
    end
    describe "when wrap to new page, and first line of new page" +
             " is the start of a new paragraph, that line should" +
             " be indented" do
      it "should indent the paragraphs" do
        hello = "hello " * 50
        hello2 = "hello " * 50
        @pdf.move_cursor_to(@pdf.font.height * 3)
        @pdf.text(hello + "\n" + hello2, :indent_paragraphs => 60)
        text = PDF::Inspector::Text.analyze(@pdf.render)
        text.strings[0].should == ("hello " * 19).strip
        text.strings[1].should == ("hello " * 21).strip
        text.strings[3].should == ("hello " * 19).strip
        text.strings[4].should == ("hello " * 21).strip
      end
    end
    describe "when a paragraphs are separated by by a new line" do
      it "should not create multiple pages" do
        @pdf.text("Paragraph 1\n\nParagraph 2", :indent_paragraphs => 10)
        text = PDF::Inspector::Page.analyze(@pdf.render)
        text.pages.size.should == 1
      end
      it "should separate the paragraphs by a new line" do
        @pdf.text("Paragraph 1\n\nParagraph 2", :indent_paragraphs => 10)
        text = PDF::Inspector::Text.analyze(@pdf.render)
        text.strings.size.should == 3
      end
    end
  end
end
