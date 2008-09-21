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
  
end    


describe "Font size calculations" do
  before(:each) do
    create_pdf
    @font = @pdf.font
  end
  
  it "should require a line width option" do
    assert_raises(ArgumentError) do
      @font.height_of("Foo")
    end
  end
  
  it "should equal the number of lines * font.height by default" do
    actual_height = @pdf.font.height_of("Foo\nBar\nBaz", :line_width => 200)
    actual_height.should == 3 * @pdf.font.height
  end
  
  it "should consider spacing when provided" do
    spacing = 10
    actual_height = @pdf.font.height_of("Foo\nBar\nBaz", 
      :line_width => 200, :spacing => spacing)
    actual_height.should == 3 * @pdf.font.height + 3 * spacing
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

describe "Document#page_fonts" do
  before(:each) { create_pdf } 
  
  it "should register the current font when changing pages" do
    @pdf.font "Courier"
    page_should_include_font("Courier") 
    @pdf.start_new_page  
    page_should_include_font("Courier")       
  end 
  
  it "should register fonts properly by page" do
    @pdf.font "Courier"
    @pdf.font "Helvetica"
    @pdf.font "Times-Roman"          
    ["Courier","Helvetica","Times-Roman"].each { |f|
      page_should_include_font(f)
    }                                        
    
    @pdf.start_new_page    
    @pdf.font "Helvetica"
    ["Times-Roman","Helvetica"].each { |f|
      page_should_include_font(f)    
    }    
    page_should_not_include_font("Courier")                           
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
    
    
    
    