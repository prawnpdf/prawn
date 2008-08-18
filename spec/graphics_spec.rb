# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

class LineDrawingObserver
  attr_accessor :points, :strokes

  def initialize
    @points = [] 
  end  

  def append_line(*params)
    @points << params
  end    
             
  def begin_new_subpath(*params)
    @points << params
  end
  
end                    
           
describe "When drawing a line" do
   
  before(:each) { create_pdf }
 
  it "should draw a line from (100,600) to (100,500)" do
    @pdf.line([100,600],[100,500])
    
    line_drawing = observer(LineDrawingObserver)
    
    line_drawing.points.should == [[100,600],[100,500]]       
  end  
  
  it "should draw two lines at (100,600) to (100,500) " +
     "and (75,100) to (50,125)" do 
    @pdf.line(100,600,100,500) 
    @pdf.line(75,100,50,125)
    
    line_drawing = observer(LineDrawingObserver)
    
    line_drawing.points.should == 
      [[100.0, 600.0], [100.0, 500.0], [75.0, 100.0], [50.0, 125.0]]
  end
  
  class LineWidthReader 
    attr_accessor :width
    def set_line_width(params)
      @width = params
    end
  end
  
  it "should properly set line width" do
     create_pdf
     @pdf.line_width = 10
     line = observer(LineWidthReader)
     line.width.should == 10 
  end   
  
  describe "(Horizontally)" do  
   
    before :each do
      @pdf = Prawn::Document.new
      @pdf.horizontal_line(100,150)
      @line = observer(LineDrawingObserver) 
    end
   
    it "should draw from [x1,pdf.y],[x2,pdf.y]" do
      @line.points.should == [[100.0 + @pdf.bounds.absolute_left, @pdf.y],
                              [150.0 + @pdf.bounds.absolute_left, @pdf.y]]
    end      
    
  end
        
end                            

describe "When drawing a polygon" do

  before(:each) { create_pdf }

  it "should draw each line passed to polygon()" do
    @pdf.polygon([100,500],[100,400],[200,400])

    line_drawing = observer(LineDrawingObserver)
    line_drawing.points.should == [[100,500],[100,400],[200,400],[100,500]]
  end

end                                

class RectangleDrawingObserver
  
  attr_reader :point, :width, :height
  
  def append_rectangle(*params) 
    @point  = params[0..1]    
    @width  = params[2]
    @height = params[3]      
  end
end

describe "When drawing a rectangle" do

  before(:each) { create_pdf }

  it "should use a point, width, and height for coords" do
    @pdf.rectangle [200,200], 50, 100

    rectangle = observer(RectangleDrawingObserver)
    # PDF uses bottom left corner
    rectangle.point.should  == [200,100]
    rectangle.width.should  == 50
    rectangle.height.should == 100

  end

end

class CurveObserver
     
  attr_reader :coords
  
  def initialize
    @coords = []          
  end   
  
  def begin_new_subpath(*params)   
    @coords += params
  end
  
  def append_curved_segment(*params)
    @coords += params
  end           
  
end   

describe "When drawing a curve" do  
    
  before(:each) { create_pdf }
  
  it "should draw a bezier curve from 50,50 to 100,100" do
    @pdf.move_to  [50,50]
    @pdf.curve_to [100,100],:bounds => [[20,90], [90,70]]
    curve = observer(CurveObserver) 
    curve.coords.should == [50.0, 50.0, 20.0, 90.0, 90.0, 70.0, 100.0, 100.0] 
  end                             
  
  it "should draw a bezier curve from 100,100 to 50,50" do
    @pdf.curve [100,100], [50,50], :bounds => [[20,90], [90,75]] 
    curve = observer(CurveObserver)
    curve.coords.should == [100.0, 100.0, 20.0, 90.0, 90.0, 75.0, 50.0, 50.0] 
  end
  
end 

describe "When drawing an ellipse" do
  before(:each) do 
    create_pdf
    @pdf.ellipse_at [100,100], 25, 50
    @curve = observer(CurveObserver) 
  end       
  
  it "should move the pointer to the center of the ellipse after drawing" do
    @curve.coords[-2..-1].should == [100,100]
  end 
  
end    

describe "When drawing a circle" do
  before(:each) do 
    create_pdf
    @pdf.circle_at [100,100], :radius => 25 
    @pdf.ellipse_at [100,100], 25, 25
    @curve = observer(CurveObserver) 
  end       
  
  it "should stroke the same path as the equivalent ellipse" do 
    middle = @curve.coords.length / 2
    @curve.coords[0...middle].should == @curve.coords[middle..-1] 
  end
end    

class ColorObserver 
  attr_reader :stroke_color, :fill_color, :stroke_color_count, 
              :fill_color_count
                            
  def initialize
    @stroke_color_count = 0
    @fill_color_count   = 0
  end

  def set_rgb_color_for_stroking(*params)    
    @stroke_color_count += 1
    @stroke_color = params
  end

  def set_rgb_color_for_nonstroking(*params) 
    @fill_color_count += 1
    @fill_color = params
  end
end

describe "When setting colors" do

  before(:each) { create_pdf }

  it "should set stroke colors" do
    @pdf.stroke_color "ffcccc"
    colors = observer(ColorObserver)
    # 100% red, 80% green, 80% blue
    colors.stroke_color.should == [1.0, 0.8, 0.8]
  end

  it "should set fill colors" do
    @pdf.fill_color "ccff00"
    colors = observer(ColorObserver)
    # 80% red, 100% green, 0% blue
    colors.fill_color.should == [0.8,1.0,0]
  end   
  
  it "should reset the colors on each new page if they have been defined" do
    @pdf.fill_color "ccff00"
    colors = observer(ColorObserver)
    
    colors.fill_color_count.should == 2   
    colors.stroke_color_count.should == 1
    @pdf.start_new_page                
    @pdf.stroke_color "ff00cc"  
    
    colors = observer(ColorObserver)
    colors.fill_color_count.should == 3  
    colors.stroke_color_count.should == 3
    
    @pdf.start_new_page
    colors = observer(ColorObserver)
    colors.fill_color_count.should == 4
    colors.stroke_color_count.should == 4
    
    colors.fill_color.should   == [0.8,1.0,0.0]
    colors.stroke_color.should == [1.0,0.0,0.8] 
  end
    

end

describe "When using painting shortcuts" do
  before(:each) { create_pdf }
 
  it "should convert stroke_some_method(args) into some_method(args); stroke" do
    @pdf.expects(:line_to).with([100,100])
    @pdf.expects(:stroke)
    
    @pdf.stroke_line_to [100,100]
  end  
  
  it "should convert fill_some_method(args) into some_method(args); fill" do
    @pdf.expects(:line_to).with([100,100]) 
    @pdf.expects(:fill)
    
    @pdf.fill_line_to [100,100]
  end
  
  it "should not break method_missing" do
    lambda { @pdf.i_have_a_pretty_girlfriend_named_jia }.
      should.raise(NoMethodError) 
  end
end
