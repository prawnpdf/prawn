# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "#height_of_formatted with inline styling" do
  before(:each) { create_pdf }

  it "should return the height that would be required to print a" +
    "particular string of text" do
    original_y = @pdf.y
    array = [:text => "Foo"]
    @pdf.formatted_text(array)
    new_y = @pdf.y
    @pdf.height_of_formatted(array,
            :width => 300).should.be.close(original_y - new_y, 0.0001)
  end

  it "should raise CannotFit if a too-small width is given" do
    lambda do
      @pdf.height_of_formatted([:text => "hai"], :width => 1)
    end.should.raise(Prawn::Errors::CannotFit)
  end

  it "should raise NotImplementedError if :indent_paragraphs option is" +
     "provided" do
    lambda {
      @pdf.height_of_formatted([:text => "hai"], :width => 300,
                               :indent_paragraphs => 60)
    }.should.raise(NotImplementedError)
  end

  it "should not raise Prawn::Errors::UnknownOption if :final_gap option" +
     "is provided" do
    lambda {
      @pdf.height_of_formatted([:text => "hai"], :width => 300,
                               :final_gap => true)
    }.should.not.raise(Prawn::Errors::UnknownOption)
  end
end

describe "#formatted_text" do
  it "should draw text" do
    create_pdf
    string = "hello world"
    format_array = [:text => string]
    @pdf.formatted_text(format_array)
    # grab the text from the rendered PDF and ensure it matches
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.first.should == string
  end
end

describe "#text with inline styling" do
  before(:each) { create_pdf }

  it "should advance down the document based on font_height" do
    position = @pdf.y
    @pdf.text "Foo", :inline_format => true

    @pdf.y.should.be.close(position - @pdf.font.height, 0.0001)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz", :inline_format => true
    @pdf.y.should.be.close(position - 3*@pdf.font.height, 0.0001)
  end

  it "should advance down the document based on font_height" +
    " with size option" do
    position = @pdf.y
    @pdf.text "Foo", :size => 15, :inline_format => true

    @pdf.font_size = 15
    @pdf.y.should.be.close(position - @pdf.font.height, 0.0001)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz", :inline_format => true
    @pdf.y.should.be.close(position - 3*@pdf.font.height, 0.0001)
  end

  it "should advance down the document based on font_height" +
    " with leading option" do
    position = @pdf.y
    leading = 2
    @pdf.text "Foo", :leading => leading, :inline_format => true

    @pdf.y.should.be.close(position - @pdf.font.height - leading, 0.0001)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz", :inline_format => true
    @pdf.y.should.be.close(position - 3*@pdf.font.height, 0.0001)
  end

  it "should advance down the document based on font ascender only "+
    "if final_gap is given" do
    position = @pdf.y
    @pdf.text "Foo", :final_gap => false, :inline_format => true

    @pdf.y.should.be.close(position - @pdf.font.ascender, 0.0001)

    position = @pdf.y
    @pdf.text "Foo\nBar\nBaz", :final_gap => false, :inline_format => true
    @pdf.y.should.be.close(position -
                           2*@pdf.font.height -
                           @pdf.font.ascender, 0.0001)
  end

  it "should be able to print text starting at the last line of a page" do
    @pdf.move_cursor_to(@pdf.font.height)
    @pdf.text("hello world", :inline_format => true)
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 1
  end

  it "should automatically move to a new page if the tallest fragment" +
     " on the next line won't fit in the available space" do
    create_pdf
    @pdf.move_cursor_to(@pdf.font.height)
    formatted = "this contains <font size='24'>sized</font> text"
    @pdf.text(formatted, :inline_format => true)
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 2
  end

  it "should raise an exception when an unknown font is used" do
    lambda { @pdf.font "Pao bu" }.should.raise(Prawn::Errors::UnknownFont)
  end

  it "should correctly render a utf-8 string when using a built-in font" do
    str = "©" # copyright symbol
    @pdf.text str, :inline_format => true

    # grab the text from the rendered PDF and ensure it matches
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings.first.should == str
  end

  it "should correctly render a string with higher bit characters across" +
     " a page break when using a built-in font" do
    str = "©"
    @pdf.move_cursor_to(@pdf.font.height)
    @pdf.text(str + "\n" + str, :inline_format => true)

    # grab the text from the rendered PDF and ensure it matches
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[1].should == str.strip
  end

  it "should correctly render a string with higher bit characters across" +
    " a page break when using a built-in font and :indent_paragraphs option" do
    str = "©"
    @pdf.move_cursor_to(@pdf.font.height)
    @pdf.text(str + "\n" + str,
              :indent_paragraphs => 20,
              :inline_format => true)

    # grab the text from the rendered PDF and ensure it matches
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.strings[1].should == str.strip
  end

  if "spec".respond_to?(:encode!)
    # Handle non utf-8 string encodings in a sane way on M17N aware VMs
    it "should raise an exception when a utf-8 incompatible string is rendered" do
      str = "Blah \xDD"
      str.force_encoding("ASCII-8BIT")
      lambda { @pdf.text str,
          :inline_format => true }.should.raise(ArgumentError)
    end
    it "should not raise an exception when a shift-jis string is rendered" do
      datafile = "#{Prawn::BASEDIR}/data/shift_jis_text.txt"
      sjis_str = File.open(datafile, "r:shift_jis") { |f| f.gets }
      @pdf.font_families["gkai00mp"] = {
        :normal      => { :file => "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf",
                          :font => "gkai00mp" }
      }
      @pdf.font("gkai00mp")
      lambda { @pdf.text sjis_str,
          :inline_format => true }.should.not.raise(ArgumentError)
    end
  else
    # Handle non utf-8 string encodings in a sane way on non-M17N aware VMs
    it "should raise an exception when a corrupt utf-8 string is rendered" do
      str = "Blah \xDD"
      lambda { @pdf.text str,
          :inline_format => true }.should.raise(ArgumentError)
    end
    it "should raise an exception when a shift-jis string is rendered" do
      sjis_str = File.read("#{Prawn::BASEDIR}/data/shift_jis_text.txt")
      lambda { @pdf.text sjis_str,
          :inline_format => true }.should.raise(ArgumentError)
    end
  end
end
