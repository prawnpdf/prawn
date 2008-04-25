require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  
                  
describe "When drawing a line" do
     
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
    
  before :each do
     @pdf = Prawn::Document.new 
  end
 
  it "should draw and stroke a line from (100,600) to (100,500)" do
    @pdf.line(100,600,100,500)
    
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
  
  def detect_lines        
    output = @pdf.render
    obs = LineDrawingObserver.new
    PDF::Reader.string(output,obs) 
    return obs
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
  
  
  before :each do
    @pdf = Prawn::Document.new
  end
  
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