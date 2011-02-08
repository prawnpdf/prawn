# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

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

  it "should automatically move to a new page if the tallest fragment" +
     " on the next line won't fit in the available space" do
    create_pdf
    @pdf.move_cursor_to(@pdf.font.height)
    formatted = "this contains <font size='24'>sized</font> text"
    @pdf.text(formatted, :inline_format => true)
    pages = PDF::Inspector::Page.analyze(@pdf.render).pages
    pages.size.should == 2
  end

  it "should embed links as literal strings" do
    @pdf.text "<link href='http://wiki.github.com/sandal/prawn/'>wiki</link>",
      :inline_format => true
    @pdf.render.should =~ %r{/URI\s+\(http://wiki\.github\.com}
  end
end
