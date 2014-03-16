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
    @pdf.height_of("Foo").should be_within(0.0001).of(original_y - new_y)
  end

  it "should omit the gap below the last descender if :final_gap => false " +
    "is given" do
    original_y = @pdf.y
    @pdf.text("Foo", :final_gap => false)
    new_y = @pdf.y
    @pdf.height_of("Foo", :final_gap => false).should be_within(0.0001).of(original_y - new_y)
  end

  it "should raise_error CannotFit if a too-small width is given" do
    lambda do
      @pdf.height_of("text", :width => 1)
    end.should raise_error(Prawn::Errors::CannotFit)
  end

  it "should raise_error NotImplementedError if :indent_paragraphs option is provided" do
    lambda {
      @pdf.height_of("hai", :width => 300,
                     :indent_paragraphs => 60)
    }.should raise_error(NotImplementedError)
  end

  it "should_not raise_error Prawn::Errors::UnknownOption if :final_gap option is provided" do
    @pdf.height_of("hai", :width => 300, :final_gap => true)
  end
end

describe "#text" do
  before(:each) { create_pdf }

  it "should not fail when @output is nil when PDF::Core::Text::LineWrap#finalize_line is called" do
    # need a document with margins for these particulars to produce the
    # condition that was throwing the error
    pdf = Prawn::Document.new
    pdf.text "transparency " * 150, :size => 18
  end

  it "should allow drawing empty strings to the page" do
    @pdf.text " "
    text = PDF::Inspector::Text.analyze(@pdf.render)
    # If anything is rendered to the page, it should be whitespace.
    text.strings.each { |str| str.should =~ /\A\s*\z/ }
  end

  it "should ignore call when string is nil" do
    @pdf.text(nil).should be_false
  end

  it "should correctly render empty paragraphs" do
    @pdf.text "text\n\ntext"
    text = PDF::Inspector::Text.analyze(@pdf.render)
    @pdf.page_count.should == 1
    text.strings.reject{ |s| s.empty? }.should == ["text", "text"]
  end

  it "should correctly render empty paragraphs with :indent_paragraphs" do
    @pdf.text "text\n\ntext", :indent_paragraphs => 5
    text = PDF::Inspector::Text.analyze(@pdf.render)
    @pdf.page_count.should == 1
    text.strings.reject{ |s| s.empty? }.should == ["text", "text"]
  end

  it "should correctly render strings ending with empty paragraphs and " +
     ":inline_format and :indent_paragraphs" do
    @pdf.text "text\n\n", :inline_format => true, :indent_paragraphs => 5
    text = PDF::Inspector::Text.analyze(@pdf.render)
    @pdf.page_count.should == 1
    text.strings.should == ["text"]
  end

  it "should default to use kerning information" do
    @pdf.text "hello world"
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.kerned[0].should be_true
  end

  it "should be able to disable kerning with an option" do
    @pdf.text "hello world", :kerning => false
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.kerned[0].should be_false
  end

  it "should be able to disable kerning document-wide" do
    @pdf.default_kerning(false)
    @pdf.default_kerning = false
    @pdf.text "hello world"
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.kerned[0].should be_false
  end

  it "option should be able to override document-wide kerning disabling" do
    @pdf.default_kerning = false
    @pdf.text "hello world", :kerning => true
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.kerned[0].should be_true
  end

  it "should raise_error ArgumentError if :at option included" do
    lambda { @pdf.text("hai", :at => [0, 0]) }.should raise_error(ArgumentError)
  end

  it "should advance down the document based on font_height" do
    position = @pdf.y
    @pdf.text "Foo"

    @pdf.y.should be_within(0.0001).of(position - @pdf.font.height)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz"
    @pdf.y.should be_within(0.0001).of(position - 3*@pdf.font.height)
  end

  it "should advance down the document based on font_height" +
    " with size option" do
    position = @pdf.y
    @pdf.text "Foo", :size => 15

    @pdf.font_size = 15
    @pdf.y.should be_within(0.0001).of(position - @pdf.font.height)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz"
    @pdf.y.should be_within(0.0001).of(position - 3 * @pdf.font.height)
  end

  it "should advance down the document based on font_height" +
    " with leading option" do
    position = @pdf.y
    leading = 2
    @pdf.text "Foo", :leading => leading

    @pdf.y.should be_within(0.0001).of(position - @pdf.font.height - leading)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz"
    @pdf.y.should be_within(0.0001).of(position - 3*@pdf.font.height)
  end

  it "should advance only to the bottom of the final descender "+
    "if final_gap is false" do
    position = @pdf.y
    @pdf.text "Foo", :final_gap => false

    @pdf.y.should be_within(0.0001).of(position - @pdf.font.ascender - @pdf.font.descender)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz", :final_gap => false
    @pdf.y.should be_within(0.0001).of(position - 2*@pdf.font.height - @pdf.font.ascender - @pdf.font.descender)
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

  it "should raise_error an exception when an unknown font is used" do
    lambda { @pdf.font "Pao bu" }.should raise_error(Prawn::Errors::UnknownFont)
  end

  it "should_not raise_error an exception when providing Pathname instance as font" do
    @pdf.font Pathname.new("#{Prawn::DATADIR}/fonts/DejaVuSans.ttf")
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
    @pdf.font "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
    @pdf.text str

    # grab the text from the rendered PDF and ensure it matches
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.first.should == str
  end

  it "subsets mixed low-ASCII and non-ASCII characters when they can be " +
     "subsetted together" do
    str = "It’s super effective!"
    @pdf.font "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
    @pdf.text str

    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.first.should == str
  end

  it "should correctly render a string with higher bit characters across" +
     " a page break when using a built-in font" do
    str = "©"
    @pdf.move_cursor_to(@pdf.font.height)
    @pdf.text(str + "\n" + str)

    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 2
    pages[0][:strings].should == [str]
    pages[1][:strings].should == [str]
  end

  it "should correctly render a string with higher bit characters across" +
    " a page break when using a built-in font and :indent_paragraphs option" do
    str = "©"
    @pdf.move_cursor_to(@pdf.font.height)
    @pdf.text(str + "\n" + str, :indent_paragraphs => 20)

    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 2
    pages[0][:strings].should == [str]
    pages[1][:strings].should == [str]
  end

  it "should raise_error an exception when a utf-8 incompatible string is rendered" do
    str = "Blah \xDD"
    str.force_encoding(Encoding::ASCII_8BIT)
    lambda { @pdf.text str }.should raise_error(
      Prawn::Errors::IncompatibleStringEncoding)
  end

  it "should_not raise_error an exception when a shift-jis string is rendered" do
    datafile = "#{Prawn::DATADIR}/shift_jis_text.txt"
    sjis_str = File.open(datafile, "r:shift_jis") { |f| f.gets }
    @pdf.font("#{Prawn::DATADIR}/fonts/gkai00mp.ttf")

    # Expect that the call to text will not raise an encoding error
    @pdf.text(sjis_str)
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
  end

  describe "kerning" do
    it "should respect text kerning setting (document default)" do
      create_pdf
      @pdf.font.expects(:compute_width_of).with do |str, options|
        str == "VAT" && options[:kerning] == true
      end.at_least_once.returns(10)
      @pdf.text "VAT"
    end

    it "should respect text kerning setting (kerning=true)" do
      create_pdf
      @pdf.font.expects(:compute_width_of).with do |str, options|
        str == "VAT" && options[:kerning] == true
      end.at_least_once.returns(10)
      @pdf.text "VAT", :kerning => true
    end

    it "should respect text kerning setting (kerning=false)" do
      create_pdf
      @pdf.font.expects(:compute_width_of).with do |str, options|
        str == "VAT" && options[:kerning] == false
      end.at_least_once.returns(10)
      @pdf.text "VAT", :kerning => false
    end
  end

  describe "#shrink_to_fit with special utf-8 text" do
    it "Should not throw an exception", 
        :unresolved, :issue => 603 do
      pages = 0
      doc = Prawn::Document.new(page_size: 'A4', margin: [2, 2, 2, 2]) do |pdf|
        add_unicode_fonts(pdf)
        pdf.bounding_box([1, 1], :width => 90, :height => 50) do
          broken_text = " Sample Text\nSAMPLE SAMPLE SAMPLEoddělení ZMĚN\nSAMPLE"
          pdf.text broken_text, :overflow => :shrink_to_fit
        end
      end
    end
  end


  def add_unicode_fonts(pdf)
    dejavu = "#{::Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
    pdf.font_families.update("dejavu" => {
      :normal      => dejavu,
      :italic      => dejavu,
      :bold        => dejavu,
      :bold_italic => dejavu
    })
    pdf.fallback_fonts = ["dejavu"]
  end
end
