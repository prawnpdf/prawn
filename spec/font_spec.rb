# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")           

describe "Font Metrics" do  

  it "should default to Helvetica if no font is specified" do
    @pdf = Prawn::Document.new
    @pdf.font.metrics.should == Prawn::Font::Metrics["Helvetica"]
  end

  it "should use the currently set font for font_metrics" do
    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    @pdf.font.metrics.should == Prawn::Font::Metrics["Courier"]
   
    comicsans = "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf"
    @pdf.font(comicsans)
    @pdf.font.metrics.should == Prawn::Font::Metrics[comicsans]
  end 

  it "should wrap text" do
    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    @pdf.font.metrics.naive_wrap("Please wrap this text about HERE. More text that should be wrapped", 220, @pdf.font.size).should ==
				 "Please wrap this text about\nHERE. More text that should be\nwrapped"
  end

  it "should respect end of line when wrapping text" do
    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    text = "Please wrap only before\nTHIS word. Don't wrap this"
    @pdf.font.metrics.naive_wrap(text, 220, @pdf.font.size).should == text
  end

  it "should respect end of line when wrapping text and mode is set to 'character'" do
    @pdf = Prawn::Document.new
    @pdf.font "Courier"
    opts = {:mode => :character}
    @pdf.font.metrics.naive_wrap("You can wrap this text HERE", 180, @pdf.font.size, opts).should ==
				 "You can wrap this text HE\nRE"
  end     
  
end    

describe "font style support" do
  before(:each) { create_pdf }
  
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
      
end

describe "Transactional font handling" do
  before(:each) { create_pdf }
  
  it "should allow setting of size directly when font is created" do
    @pdf.font "Courier", :size => 16
    @pdf.font.size.should == 16 
  end
  
  it "should allow temporary setting of a new font using a transaction" do
    original = @pdf.font
    
    @pdf.font "Courier", :size => 16 do
      @pdf.font.name.should == "Courier"
      @pdf.font.size.should == 16
    end
    
    @pdf.font.should == original  
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
    @pdf.page_fonts.values.map { |e| e.data[:BaseFont] }.include?(font.to_sym)
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
    
    
    
    
