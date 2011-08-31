# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")           
require 'iconv'

describe "Font behavior" do  

  it "should default to Helvetica if no font is specified" do
    @pdf = Prawn::Document.new
    @pdf.font.name.should == "Helvetica"
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
    @pdf.font("#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf")

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
    
    inline_bold_hello.should.be > normal_hello
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
      should.raise(Prawn::Errors::NotOnPage)
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
    file = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
    @pdf.font_families["Action Man"] = {
      :normal      => { :file => file, :font => "ActionMan" },
      :italic      => { :file => file, :font => "ActionMan-Italic" },
      :bold        => { :file => file, :font => "ActionMan-Bold" },
      :bold_italic => { :file => file, :font => "ActionMan-BoldItalic" }
    }

    @pdf.font "Action Man", :style => :italic
    @pdf.text "In ActionMan-Italic"

    text = PDF::Inspector::Text.analyze(@pdf.render)
    name = text.font_settings.map { |e| e[:name] }.first.to_s
    name = name.sub(/\w+\+/, "subset+")
    name.should == "subset+ActionMan-Italic"
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
    assert_block("Expected page to include font: #{font}") do
      page_includes_font?(font)
    end
  end   
  
  def page_should_not_include_font(font)
    assert_block("Did not expect page to include font: #{font}") do
      not page_includes_font?(font) 
    end
  end
      
end
    
describe "AFM fonts" do
  
  setup do
    create_pdf
    @times = @pdf.find_font "Times-Roman"
    @iconv = ::Iconv.new('Windows-1252', 'utf-8')
  end
  
  it "should calculate string width taking into account accented characters" do
    @times.compute_width_of(@iconv.iconv("é"), :size => 12).should == @times.compute_width_of("e", :size => 12)
  end
  
  it "should calculate string width taking into account kerning pairs" do
    @times.compute_width_of(@iconv.iconv("To"), :size => 12).should == 13.332
    @times.compute_width_of(@iconv.iconv("To"), :size => 12, :kerning => true).should == 12.372
    @times.compute_width_of(@iconv.iconv("Tö"), :size => 12, :kerning => true).should == 12.372
  end

  it "should encode text without kerning by default" do
    @times.encode_text(@iconv.iconv("To")).should == [[0, "To"]]
    @times.encode_text(@iconv.iconv("Télé")).should == [[0, @iconv.iconv("Télé")]]
    @times.encode_text(@iconv.iconv("Technology")).should == [[0, "Technology"]]
    @times.encode_text(@iconv.iconv("Technology...")).should == [[0, "Technology..."]]
  end

  it "should encode text with kerning if requested" do
    @times.encode_text(@iconv.iconv("To"), :kerning => true).should == [[0, ["T", 80, "o"]]]
    @times.encode_text(@iconv.iconv("Télé"), :kerning => true).should == [[0, ["T", 70, @iconv.iconv("élé")]]]
    @times.encode_text(@iconv.iconv("Technology"), :kerning => true).should == [[0, ["T", 70, "echnology"]]]
    @times.encode_text(@iconv.iconv("Technology..."), :kerning => true).should == [[0, ["T", 70, "echnology", 65, "..."]]]
  end

  describe "when normalizing encoding" do

    it "should not modify the original string when normalize_encoding() is used" do
      original = "Foo"
      normalized = @times.normalize_encoding(original)
      assert ! original.equal?(normalized)
    end

    it "should modify the original string when normalize_encoding!() is used" do
      original = "Foo"
      normalized = @times.normalize_encoding!(original)
      assert original.equal?(normalized)
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
    font.glyph_present?("H").should.be true
  end

  it "should return false when absent in an AFM font" do
    font = @pdf.find_font("Helvetica")
    font.glyph_present?("再").should.be false
  end

  it "should return true when present in a TTF font" do
    font = @pdf.find_font("#{Prawn::BASEDIR}/data/fonts/Activa.ttf")
    font.glyph_present?("H").should.be true
  end

  it "should return false when absent in a TTF font" do
    font = @pdf.find_font("#{Prawn::BASEDIR}/data/fonts/Activa.ttf")
    font.glyph_present?("再").should.be false

    font = @pdf.find_font("#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf")
    font.glyph_present?("€").should.be false
  end
end

describe "TTF fonts" do
  
  setup do
    create_pdf
    @activa = @pdf.find_font "#{Prawn::BASEDIR}/data/fonts/Activa.ttf"
  end
  
  it "should calculate string width taking into account accented characters" do
    @activa.compute_width_of("é", :size => 12).should == @activa.compute_width_of("e", :size => 12)
  end
  
  it "should calculate string width taking into account kerning pairs" do
    @activa.compute_width_of("To", :size => 12).should == 15.228
    @activa.compute_width_of("To", :size => 12, :kerning => true).should == 12.996
  end
  
  it "should encode text without kerning by default" do
    @activa.encode_text("To").should == [[0, "To"]]

    tele = (RUBY_VERSION < '1.9') ? "T\216l\216" :
      "T\216l\216".force_encoding("US-ASCII")
    @activa.encode_text("Télé").should == [[0, tele]]

    @activa.encode_text("Technology").should == [[0, "Technology"]]
    @activa.encode_text("Technology...").should == [[0, "Technology..."]]
    @activa.encode_text("Teχnology...").should == [[0, "Te"], [1, "!"], [0, "nology..."]]
  end

  it "should encode text with kerning if requested" do
    @activa.encode_text("To", :kerning => true).should == [[0, ["T", 186.0, "o"]]]
    @activa.encode_text("To", :kerning => true).should == [[0, ["T", 186.0, "o"]]]
    @activa.encode_text("Technology", :kerning => true).should == [[0, ["T", 186.0, "echnology"]]]
    @activa.encode_text("Technology...", :kerning => true).should == [[0, ["T", 186.0, "echnology", 88.0, "..."]]]
    @activa.encode_text("Teχnology...", :kerning => true).should == [[0, ["T", 186.0, "e"]], [1, "!"], [0, ["nology", 88.0, "..."]]]
  end

  it "should use the ascender, descender, and cap height from the TTF verbatim" do
    # These metrics are relative to the font's own bbox. They should not be
    # scaled with font size.
    ref = @pdf.ref!({})
    @activa.send :embed, ref, 0

    # Pull out the embedded font descriptor
    descriptor = ref.data[:FontDescriptor].data
    descriptor[:Ascent].should == 804
    descriptor[:Descent].should == -195
    descriptor[:CapHeight].should == 804
  end

  describe "when normalizing encoding" do

    it "should not modify the original string when normalize_encoding() is used" do
      original = "Foo"
      normalized = @activa.normalize_encoding(original)
      assert ! original.equal?(normalized)
    end

    it "should modify the original string when normalize_encoding!() is used" do
      original = "Foo"
      normalized = @activa.normalize_encoding!(original)
      assert original.equal?(normalized)
    end

  end

  describe "when used with snapshots or transactions" do
    
    it "should allow TTF fonts to be used alongside document transactions" do
      lambda {
        Prawn::Document.new do
          font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
          text "Hi there"
          transaction { text "Nice, thank you" }
        end
      }.should.not.raise
    end

    it "should allow TTF fonts to be used inside transactions" do
      pdf = Prawn::Document.new do
        transaction do
          font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
          text "Hi there"
        end
      end

      text = PDF::Inspector::Text.analyze(pdf.render)
      name = text.font_settings.map { |e| e[:name] }.first.to_s
      name = name.sub(/\w+\+/, "subset+")
      name.should == "subset+DejaVuSans"
    end

  end
  
end

describe "DFont fonts" do
  setup do
    create_pdf
    @file = "#{Prawn::BASEDIR}/data/fonts/Action Man.dfont"
  end

  it "should list all named fonts" do
    list = Prawn::Font::DFont.named_fonts(@file)
    list.sort.should == %w(ActionMan ActionMan-Italic ActionMan-Bold ActionMan-BoldItalic).sort
  end

  it "should count the number of fonts in the file" do
    Prawn::Font::DFont.font_count(@file).should == 4
  end

  it "should default selected font to the first one if not specified" do
    font = @pdf.find_font(@file)
    font.basename.should == "ActionMan"
  end

  it "should allow font to be selected by index" do
    font = @pdf.find_font(@file, :font => 2)
    font.basename.should == "ActionMan-Italic"
  end

  it "should allow font to be selected by name" do
    font = @pdf.find_font(@file, :font => "ActionMan-BoldItalic")
    font.basename.should == "ActionMan-BoldItalic"
  end

  it "should cache font object based on selected font" do
    f1 = @pdf.find_font(@file, :font => "ActionMan")
    f2 = @pdf.find_font(@file, :font => "ActionMan-Bold")
    assert_not_equal f1.object_id, f2.object_id
    assert_equal f1.object_id, @pdf.find_font(@file, :font => "ActionMan").object_id
    assert_equal f2.object_id, @pdf.find_font(@file, :font => "ActionMan-Bold").object_id
  end
end

describe "#character_count(text)" do
  it "should work on TTF fonts" do
    create_pdf
    @pdf.font("#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf")
    @pdf.font.character_count("こんにちは世界").should == 7
    @pdf.font.character_count("Hello, world!").should == 13
  end

  it "should work on AFM fonts" do
    create_pdf
    @pdf.font.character_count("Hello, world!").should == 13
  end
end
