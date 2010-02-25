# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")           
require 'iconv'

describe "Font behavior" do  

  it "should default to Helvetica if no font is specified" do
    @pdf = Prawn::Document.new
    @pdf.font.name.should == "Helvetica"
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
    @activa.encode_text("Télé").should == [[0, "T\216l\216"]]
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
