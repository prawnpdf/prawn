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
    output = @pdf.render
    
    line_drawing = LineDrawingObserver.new
    PDF::Reader.string(output, line_drawing)  
    
    line_drawing.points.should == [[100,600],[100,500]]       
    line_drawing.strokes.should == 1
  end  
  
  it "should draw two lines (100,600) to (100,500) and stroke only once" +
     "and (75,100) to (50,125)" do 
    @pdf.line(100,600,100,500) 
    @pdf.line(75,100,50,125)
    output = @pdf.render
    
    line_drawing = LineDrawingObserver.new
    PDF::Reader.string(output,line_drawing) 
    
    line_drawing.points.should == 
      [[100.0, 600.0], [100.0, 500.0], [75.0, 100.0], [50.0, 125.0]]
    line_drawing.strokes.should == 1
  end                               
  
  it "should stroke twice if lines are drawn on two separate pages" do
    @pdf.line(100,600,100,500)         
    @pdf.start_new_page
    @pdf.line(75,100,50,125)
    output = @pdf.render
    
    line_drawing = LineDrawingObserver.new
    PDF::Reader.string(output,line_drawing) 
    
    line_drawing.points.should == 
      [[100.0, 600.0], [100.0, 500.0], [75.0, 100.0], [50.0, 125.0]]
    line_drawing.strokes.should == 2
  end
       
end
    