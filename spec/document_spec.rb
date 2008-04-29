require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

def create_pdf
  @pdf = Prawn::Document.new
end

class LineDrawingObserver
  attr_accessor :points, :strokes

  def initialize
    @points = [] 
    @strokes = 0
  end  

  def append_line(*params)
    @points << params
  end    
             
  def begin_new_subpath(*params)
    @points << params
  end
  
  def stroke_path   
    @strokes += 1
  end             

end    

def detect_lines        
  output = @pdf.render
  obs = LineDrawingObserver.new
  PDF::Reader.string(output,obs) 
  return obs
end                           

                  
describe "When drawing a line" do
   
  before(:each) { create_pdf }
 
  it "should draw and stroke a line from (100,600) to (100,500)" do
    @pdf.line([100,600],[100,500])
    
    line_drawing = detect_lines
    
    line_drawing.points.should == [[100,600],[100,500]]       
    line_drawing.strokes.should == 1
  end  
  
  it "should draw two lines (100,600) to (100,500) and stroke each line" +
     "and (75,100) to (50,125)" do 
    @pdf.line(100,600,100,500) 
    @pdf.line(75,100,50,125)
    
    line_drawing = detect_lines
    
    line_drawing.points.should == 
      [[100.0, 600.0], [100.0, 500.0], [75.0, 100.0], [50.0, 125.0]]
    line_drawing.strokes.should == 2
  end   
        
end                            

describe "When drawing a polygon" do

  before(:each) { create_pdf }

  it "should draw each line passed to polygon()" do
    @pdf.polygon([100,500],[100,400],[200,400])

    line_drawing = detect_lines
    line_drawing.points.should == [[100,500],[100,400],
                                   [100,400],[200,400],
                                   [200,400],[100,500]]
    line_drawing.strokes.should == 3
  end

end

describe "When drawing a rectangle" do

  before(:each) { create_pdf }

  it "should draw each line in the rectangle" do
    @pdf.rectangle [200,200], 50, 100

    line_drawing = detect_lines
    line_drawing.points.should == [[200,200],[250,200],
                                   [250,200],[250,100],
                                   [250,100],[200,100],
                                   [200,100],[200,200]]

  end

end

describe "When creating multi-page documents" do 
  
  class PageCounter
    attr_accessor :pages

    def initialize
      @pages = 0
    end

    # Called when page parsing ends
    def end_page
      @pages += 1
    end
  end
  
  
  before(:each) { create_pdf }
  
  it "should initialize with a single page" do 
    page_counter = count_pages
    
    page_counter.pages.should == 1            
    @pdf.page_count.should == 1  
  end
  
  it "should provide an accurate page_count" do
    3.times { @pdf.start_new_page }           
    page_counter = count_pages
    
    page_counter.pages.should == 4
    @pdf.page_count.should == 4
  end        
  
  def count_pages        
    output = @pdf.render
    obs = PageCounter.new
    PDF::Reader.string(output,obs) 
    return obs
  end              
  
end   

describe "When beginning each new page" do

  it "should execute the lambda specified by on_page_start" do
    on_start = mock("page_start_proc")

    on_start.should_receive(:[]).exactly(3).times
   
    pdf = Prawn::Document.new(:on_page_start => on_start)
    pdf.start_new_page 
    pdf.start_new_page
  end

end


describe "When ending each page" do

  it "should execute the lambda specified by on_page_end" do

    on_end = mock("page_end_proc")

    on_end.should_receive(:[]).exactly(3).times

    pdf = Prawn::Document.new(:on_page_end => on_end)
    pdf.start_new_page
    pdf.start_new_page
    pdf.render
  end

end                                 

class PageDetails      
  
  def begin_page(params)
    @geometry = params[:MediaBox]
  end                       
  
  def size
    @geometry[-2..-1] 
  end
  
end

def detect_page_details
  output = @pdf.render
  obs = PageDetails.new
  PDF::Reader.string(output,obs) 
  return obs      
end

describe "When setting page size" do
  it "should default to LETTER" do
    @pdf = Prawn::Document.new
    page = detect_page_details
    page.size.should == Prawn::Document::PageGeometry::SIZES["LETTER"]    
  end                                                                  
  
  (Prawn::Document::PageGeometry::SIZES.keys - ["LETTER"]).each do |k|
    it "should provide #{k} geometry" do
      @pdf = Prawn::Document.new(:page_size => k)
      page = detect_page_details
      page.size.should == Prawn::Document::PageGeometry::SIZES[k]
    end
  end
end       

describe "When setting page layout" do
  it "should reverse coordinates for landscape" do
    @pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)
    page = detect_page_details
    page.size.should == Prawn::Document::PageGeometry::SIZES["A4"].reverse
  end   
end
