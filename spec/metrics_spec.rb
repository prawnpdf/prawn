# encoding: ASCII-8BIT          

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")   

describe "adobe font metrics" do
  
  setup do
    @times = Prawn::Font::Metrics["Times-Roman"]
  end
  
  it "should calculate string width taking into account accented characters" do
    @times.string_width("é", 12).should == @times.string_width("e", 12)
  end
  
  it "should calculate string width taking into account kerning pairs" do
    @times.string_width("To", 12).should == 13.332
    @times.string_width("To", 12, :kerning => true).should == 12.372
    @times.string_width("Tö", 12, :kerning => true).should == 12.372
  end
  
  it "should kern a string" do
    @times.kern("To").should == ["T", 80, "o"]
    @times.kern("Télé").should == ["T", 70, "\303\251l\303\251"]
    @times.kern("Technology").should == ["T", 70, "echnology"]
    @times.kern("Technology...").should == ["T", 70, "echnology", 65, "..."]
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
    @activa.kern("To").should == ["\0007", 186.0, "\000R"]
    
    # Does activa use kerning classes here? Ruby/TTF doesn't support
    # format 2 kerning tables, so don't bother for now.
    
    # @activa.kern("Télé").should == ["T", -186, "élé"]
    
    @activa.kern("Technology").should == ["\0007", 186.0, 
      "\000H\000F\000K\000Q\000R\000O\000R\000J\000\\"]
    @activa.kern("Technology...").should == ["\0007", 186.0,
       "\000H\000F\000K\000Q\000R\000O\000R\000J\000\\", 88.0, 
       "\000\021\000\021\000\021"] 
  end
  
end