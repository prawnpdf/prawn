# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  
require "iconv"

describe "adobe font metrics" do
  
  setup do
    @times = Prawn::Font::Metrics["Times-Roman"]
    @iconv = ::Iconv.new('Windows-1252', 'utf-8')
  end
  
  it "should calculate string width taking into account accented characters" do
    @times.string_width(@iconv.iconv("é"), 12).should == @times.string_width("e", 12)
  end
  
  it "should calculate string width taking into account kerning pairs" do
    @times.string_width(@iconv.iconv("To"), 12).should == 13.332
    @times.string_width(@iconv.iconv("To"), 12, :kerning => true).should == 12.372
    @times.string_width(@iconv.iconv("Tö"), 12, :kerning => true).should == 12.372
  end
  
  it "should kern a string" do
    @times.kern(@iconv.iconv("To")).should == ["T", 80, "o"]
    @times.kern(@iconv.iconv("Télé")).should == ["T", 70, @iconv.iconv("élé")]
    @times.kern(@iconv.iconv("Technology")).should == ["T", 70, "echnology"]
    @times.kern(@iconv.iconv("Technology...")).should == ["T", 70, "echnology", 65, "..."]
  end
  
end

describe "ttf font metrics" do
  
  setup do
    @activa = Prawn::Font::Metrics["#{Prawn::BASEDIR}/data/fonts/Activa.ttf"]
  end
  
  it "should calculate string width taking into account accented characters" do
    @activa.string_width("é", 12).should == @activa.string_width("e", 12)
  end
  
  it "should calculate string width taking into account kerning pairs" do
    @activa.string_width("To", 12).should == 15.228
    @activa.string_width("To", 12, :kerning => true).should.to_s == 12.996.to_s
  end
  
  it "should kern a string" do
    @activa.kern("To").should == [[84], 186.0, [111]]
    
    # Does activa use kerning classes here? Ruby/TTF doesn't support
    # format 2 kerning tables, so don't bother for now.
    
    # @activa.kern("Télé").should == ["T", -186, "élé"]
    
    @activa.kern("Technology").should == [[84], 186.0, [101, 99, 104, 110, 111, 108, 111, 103, 121]]
    @activa.kern("Technology...").should == [[84], 186.0, [101, 99, 104, 110, 111, 108, 111, 103, 121], 88.0, [46, 46, 46]]
  end
  
end
