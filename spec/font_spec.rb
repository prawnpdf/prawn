# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")
require 'pathname'

describe "Font behavior" do

  it "should default to Helvetica if no font is specified" do
    @pdf = Prawn::Document.new
    @pdf.font.name.should == "Helvetica"
  end

end

describe "Font objects" do

  it "should be equal" do
    font1 = Prawn::Document.new.font
    font2 = Prawn::Document.new.font

    font1.should eql( font2 )
  end

  it "should always be the same key" do
    font1 = Prawn::Document.new.font
    font2 = Prawn::Document.new.font

    hash = Hash.new

    hash[ font1 ] = "Original"
    hash[ font2 ] = "Overwritten"

    hash.size.should == 1

    hash[ font1 ].should == "Overwritten"
    hash[ font2 ].should == "Overwritten"
  end

end

describe "#width_of" do
  it "should take character spacing into account" do
    create_pdf
    original_width = @pdf.width_of("hello world")
    @pdf.character_spacing(7) do
      @pdf.width_of("hello world").should == original_width + 11 * 7
    end
  end

  it "should exclude newlines" do
    create_pdf
    # Use a TTF font that has a non-zero width for \n
    @pdf.font("#{Prawn::DATADIR}/fonts/gkai00mp.ttf")

    @pdf.width_of("\nhello world\n").should ==
      @pdf.width_of("hello world")
  end

  it "should take formatting into account" do
    create_pdf

    normal_hello = @pdf.width_of("hello")
    inline_bold_hello = @pdf.width_of("<b>hello</b>", :inline_format => true)
    @pdf.font("Helvetica", :style => :bold) {
      @bold_hello = @pdf.width_of("hello")
    }

    inline_bold_hello.should be > normal_hello
    inline_bold_hello.should == @bold_hello
  end

  it "should accept :style as an argument" do
    create_pdf

    styled_bold_hello = @pdf.width_of("hello", :style => :bold)
    @pdf.font("Helvetica", :style => :bold) {
      @bold_hello = @pdf.width_of("hello")
    }

    styled_bold_hello.should == @bold_hello
  end

  it "should calculate styled widths correctly using TTFs" do
    create_pdf

    @pdf.font_families.update(
      'DejaVu Sans' => {
        :normal => "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf",
        :bold => "#{Prawn::DATADIR}/fonts/DejaVuSans-Bold.ttf",
      }
    )
    @pdf.font("DejaVu Sans") {
      @styled_bold_hello = @pdf.width_of("hello", :style => :bold)
    }
    @pdf.font("DejaVu Sans", :style => :bold) {
      @bold_hello = @pdf.width_of("hello")
    }

    @pdf.font("DejaVu Sans") {
      @plain_hello = @pdf.width_of("hello")
    }

    @plain_hello.should_not == @bold_hello

    @styled_bold_hello.should == @bold_hello
  end

  it "should not treat minus as if it were a hyphen", :issue => 578 do
    create_pdf

    @pdf.width_of("-0.75").should be < @pdf.width_of("25.00")
  end
end

describe "#font_size" do
  it "should allow setting font size in DSL style" do
    create_pdf
    @pdf.font_size 20
    @pdf.font_size.should == 20
  end
end

describe "font style support" do
  before(:each) { create_pdf }

  it "should complain if there is no @current_page" do
    pdf_without_page = Prawn::Document.new(:skip_page_creation => true)

    lambda{ pdf_without_page.font "Helvetica" }.
      should raise_error(Prawn::Errors::NotOnPage)
  end

  it "should allow specifying font style by style name and font family" do
    @pdf.font "Courier", :style => :bold
    @pdf.text "In Courier bold"

    @pdf.font "Courier", :style => :bold_italic
    @pdf.text "In Courier bold-italic"

    @pdf.font "Courier", :style => :italic
    @pdf.text "In Courier italic"

    @pdf.font "Courier", :style => :normal
    @pdf.text "In Normal Courier"

    @pdf.font "Helvetica"
    @pdf.text "In Normal Helvetica"

    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings.map { |e| e[:name] }.should ==
     [:"Courier-Bold", :"Courier-BoldOblique", :"Courier-Oblique",
      :Courier, :Helvetica]
  end

  it "should allow font familes to be defined in a single dfont" do
    file = "#{Prawn::DATADIR}/fonts/Panic+Sans.dfont"
    @pdf.font_families["Panic Sans"] = {
      :normal      => { :file => file, :font => "PanicSans" },
      :italic      => { :file => file, :font => "PanicSans-Italic" },
      :bold        => { :file => file, :font => "PanicSans-Bold" },
      :bold_italic => { :file => file, :font => "PanicSans-BoldItalic" }
    }

    @pdf.font "Panic Sans", :style => :italic
    @pdf.text "In PanicSans-Italic"

    text = PDF::Inspector::Text.analyze(@pdf.render)
    name = text.font_settings.map { |e| e[:name] }.first.to_s
    name = name.sub(/\w+\+/, "subset+")
    name.should == "subset+PanicSans-Italic"
  end

  it "should accept Pathname objects for font files" do
    file = Pathname.new( "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf" )
    @pdf.font_families["DejaVu Sans"] = {
      :normal => file
    }

    @pdf.font "DejaVu Sans"
    @pdf.text "In DejaVu Sans"

    text = PDF::Inspector::Text.analyze(@pdf.render)
    name = text.font_settings.map { |e| e[:name] }.first.to_s
    name = name.sub(/\w+\+/, "subset+")
    name.should == "subset+DejaVuSans"
  end

  it "should accept IO objects for font files" do
    io = File.open "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
    @pdf.font_families["DejaVu Sans"] = {
      normal: Prawn::Font.load(@pdf, io)
    }

    @pdf.font "DejaVu Sans"
    @pdf.text "In DejaVu Sans"

    text = PDF::Inspector::Text.analyze(@pdf.render)
    name = text.font_settings.map { |e| e[:name] }.first.to_s
    name = name.sub(/\w+\+/, "subset+")
    name.should == "subset+DejaVuSans"
  end
end

describe "Transactional font handling" do
  before(:each) { create_pdf }

  it "should allow setting of size directly when font is created" do
    @pdf.font "Courier", :size => 16
    @pdf.font_size.should == 16
  end

  it "should allow temporary setting of a new font using a transaction" do
    @pdf.font "Helvetica", :size => 12

    @pdf.font "Courier", :size => 16 do
      @pdf.font.name.should == "Courier"
      @pdf.font_size.should == 16
    end

    @pdf.font.name.should == "Helvetica"
    @pdf.font_size.should == 12
  end

  it "should mask font size when using a transacation" do
    @pdf.font "Courier", :size => 16 do
      @pdf.font_size.should == 16
    end

    @pdf.font "Times-Roman"
    @pdf.font "Courier"

    @pdf.font_size.should == 12
  end

end

describe "Document#page_fonts" do
  before(:each) { create_pdf }

  it "should register fonts properly by page" do
    @pdf.font "Courier"; @pdf.text("hello")
    @pdf.font "Helvetica"; @pdf.text("hello")
    @pdf.font "Times-Roman"; @pdf.text("hello")
    ["Courier","Helvetica","Times-Roman"].each { |f|
      page_should_include_font(f)
    }

    @pdf.start_new_page
    @pdf.font "Helvetica"; @pdf.text("hello")
    page_should_include_font("Helvetica")
    page_should_not_include_font("Courier")
    page_should_not_include_font("Times-Roman")
  end

  def page_includes_font?(font)
    @pdf.page.fonts.values.map { |e| e.data[:BaseFont] }.include?(font.to_sym)
  end

  def page_should_include_font(font)
    page_includes_font?(font).should be_true
  end

  def page_should_not_include_font(font)
    page_includes_font?(font).should be_false
  end

end

describe "AFM fonts" do

  before do
    create_pdf
    @times = @pdf.find_font "Times-Roman"
  end

  it "should calculate string width taking into account accented characters" do
    input = win1252_string("\xE9")# é in win-1252
    @times.compute_width_of(input, :size => 12).should == @times.compute_width_of("e", :size => 12)
  end

  it "should calculate string width taking into account kerning pairs" do
    @times.compute_width_of(win1252_string("To"), :size => 12).should == 13.332
    @times.compute_width_of(win1252_string("To"), :size => 12, :kerning => true).should == 12.372

    input = win1252_string("T\xF6") # Tö in win-1252
    @times.compute_width_of(input, :size => 12, :kerning => true).should == 12.372
  end

  it "should encode text without kerning by default" do
    @times.encode_text(win1252_string("To")).should == [[0, "To"]]
    input = win1252_string("T\xE9l\xE9") # Télé in win-1252
    @times.encode_text(input).should == [[0, input]]
    @times.encode_text(win1252_string("Technology")).should == [[0, "Technology"]]
    @times.encode_text(win1252_string("Technology...")).should == [[0, "Technology..."]]
  end

  it "should encode text with kerning if requested" do
    @times.encode_text(win1252_string("To"), :kerning => true).should == [[0, ["T", 80, "o"]]]
    input  = win1252_string("T\xE9l\xE9") # Télé in win-1252
    output = win1252_string("\xE9l\xE9")  # élé  in win-1252
    @times.encode_text(input, :kerning => true).should == [[0, ["T", 70, output]]]
    @times.encode_text(win1252_string("Technology"), :kerning => true).should == [[0, ["T", 70, "echnology"]]]
    @times.encode_text(win1252_string("Technology..."), :kerning => true).should == [[0, ["T", 70, "echnology", 65, "..."]]]
  end

  describe "when normalizing encoding" do

    it "should not modify the original string when normalize_encoding() is used" do
      original = "Foo"
      normalized = @times.normalize_encoding(original)
      original.equal?(normalized).should be_false
    end

    it "should modify the original string when normalize_encoding!() is used" do
      original = "Foo"
      normalized = @times.normalize_encoding!(original)
      original.equal?(normalized).should be_true
    end

  end

  it "should omit /Encoding for symbolic fonts" do
    zapf = @pdf.find_font "ZapfDingbats"
    font_dict = zapf.send(:register, nil)
    font_dict.data[:Encoding].should == nil
  end

end

describe "#glyph_present" do
  before(:each) { create_pdf }

  it "should return true when present in an AFM font" do
    font = @pdf.find_font("Helvetica")
    font.glyph_present?("H").should be_true
  end

  it "should return false when absent in an AFM font" do
    font = @pdf.find_font("Helvetica")
    font.glyph_present?("再").should be_false
  end

  it "should return true when present in a TTF font" do
    font = @pdf.find_font("#{Prawn::DATADIR}/fonts/DejaVuSans.ttf")
    font.glyph_present?("H").should be_true
  end

  it "should return false when absent in a TTF font" do
    font = @pdf.find_font("#{Prawn::DATADIR}/fonts/DejaVuSans.ttf")
    font.glyph_present?("再").should be_false

    font = @pdf.find_font("#{Prawn::DATADIR}/fonts/gkai00mp.ttf")
    font.glyph_present?("€").should be_false
  end
end

describe "TTF fonts" do

  before do
    create_pdf
    @font = @pdf.find_font "#{Prawn::DATADIR}/fonts/DejaVuSans.ttf"
  end

  it "should calculate string width taking into account accented characters" do
    @font.compute_width_of("é", :size => 12).should == @font.compute_width_of("e", :size => 12)
  end

  it "should calculate string width taking into account kerning pairs" do
    @font.compute_width_of("To", :size => 12).should be_within(0.01).of(14.65)
    @font.compute_width_of("To", :size => 12, :kerning => true).should be_within(0.01).of(12.61)
  end

  it "should encode text without kerning by default" do
    @font.encode_text("To").should == [[0, "To"]]

    tele = "T\216l\216"
    result = @font.encode_text("Télé")
    result.length.should == 1
    result[0][0].should == 0
    result[0][1].bytes.to_a.should == tele.bytes.to_a

    @font.encode_text("Technology").should == [[0, "Technology"]]
    @font.encode_text("Technology...").should == [[0, "Technology..."]]
    @font.encode_text("Teχnology...").should == [[0, "Te"], [1, "!"], [0, "nology..."]]
  end

  it "should encode text with kerning if requested" do
    @font.encode_text("To", :kerning => true).should == [[0, ["T", 169.921875, "o"]]]
    @font.encode_text("Technology", :kerning => true).should == [[0, ["T", 169.921875, "echnology"]]]
    @font.encode_text("Technology...", :kerning => true).should == [[0, ["T", 169.921875, "echnology", 142.578125, "..."]]]
    @font.encode_text("Teχnology...", :kerning => true).should == [[0, ["T", 169.921875, "e"]], [1, "!"], [0, ["nology", 142.578125, "..."]]]
  end

  it "should use the ascender, descender, and cap height from the TTF verbatim" do
    # These metrics are relative to the font's own bbox. They should not be
    # scaled with font size.
    ref = @pdf.ref!({})
    @font.send :embed, ref, 0

    # Pull out the embedded font descriptor
    descriptor = ref.data[:FontDescriptor].data
    descriptor[:Ascent].should == 759
    descriptor[:Descent].should == -240
    descriptor[:CapHeight].should == 759
  end

  describe "when normalizing encoding" do
    it "should not modify the original string when normalize_encoding() is used" do
      original = "Foo"
      normalized = @font.normalize_encoding(original)
      original.equal?(normalized).should be_false
    end

    it "should modify the original string when normalize_encoding!() is used" do
      original = "Foo"
      normalized = @font.normalize_encoding!(original)
      original.equal?(normalized).should be_true
    end

  end
end

describe "DFont fonts" do
  before do
    create_pdf
    @file = "#{Prawn::DATADIR}/fonts/Panic+Sans.dfont"
  end

  it "should list all named fonts" do
    list = Prawn::Font::DFont.named_fonts(@file)
    list.sort.should == %w(PanicSans PanicSans-Italic PanicSans-Bold PanicSans-BoldItalic).sort
  end

  it "should count the number of fonts in the file" do
    Prawn::Font::DFont.font_count(@file).should == 4
  end

  it "should default selected font to the first one if not specified" do
    font = @pdf.find_font(@file)
    font.basename.should == "PanicSans"
  end

  it "should allow font to be selected by index" do
    font = @pdf.find_font(@file, :font => 2)
    font.basename.should == "PanicSans-Italic"
  end

  it "should allow font to be selected by name" do
    font = @pdf.find_font(@file, :font => "PanicSans-BoldItalic")
    font.basename.should == "PanicSans-BoldItalic"
  end

  it "should cache font object based on selected font" do
    f1 = @pdf.find_font(@file, :font => "PanicSans")
    f2 = @pdf.find_font(@file, :font => "PanicSans-Bold")
    f2.object_id.should_not == f1.object_id
    @pdf.find_font(@file, :font => "PanicSans").object_id.should == f1.object_id
    @pdf.find_font(@file, :font => "PanicSans-Bold").object_id.should == f2.object_id
  end
end

describe "#character_count(text)" do
  it "should work on TTF fonts" do
    create_pdf
    @pdf.font("#{Prawn::DATADIR}/fonts/gkai00mp.ttf")
    @pdf.font.character_count("こんにちは世界").should == 7
    @pdf.font.character_count("Hello, world!").should == 13
  end

  it "should work on AFM fonts" do
    create_pdf
    @pdf.font.character_count("Hello, world!").should == 13
  end
end
