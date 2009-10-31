# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "When drawing a line" do

  before(:each) { create_pdf }

  it "should draw a line from (100,600) to (100,500)" do
    @pdf.line([100,600],[100,500])

    line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)

    line_drawing.points.should == [[100,600],[100,500]]
  end

  it "should draw two lines at (100,600) to (100,500) " +
     "and (75,100) to (50,125)" do
    @pdf.line(100,600,100,500)
    @pdf.line(75,100,50,125)

    line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)

    line_drawing.points.should ==
      [[100.0, 600.0], [100.0, 500.0], [75.0, 100.0], [50.0, 125.0]]
  end

  it "should properly set line width via line_width=" do
     @pdf.line_width = 10
     line = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
     line.widths.first.should == 10
  end

  it "should properly set line width via line_width(width)" do
     @pdf.line_width(10)
     line = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
     line.widths.first.should == 10
  end

  describe "(Horizontally)" do
    it "should draw from [x1,pdf.y],[x2,pdf.y]" do
      @pdf.horizontal_line(100,150)
      @line = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
      @line.points.should == [[100.0 + @pdf.bounds.absolute_left, @pdf.y],
                              [150.0 + @pdf.bounds.absolute_left, @pdf.y]]
    end

    it "should draw a line from (200, 250) to (300, 250)" do
      @pdf.horizontal_line(200,300,:at => 250)
      line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
      line_drawing.points.should == [[200,250],[300,250]]
    end
  end

  describe "(Vertically)" do
    it "should draw a line from (350, 300) to (350, 400)" do
      @pdf.vertical_line(300,400,:at => 350)
      line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
      line_drawing.points.should == [[350,300],[350,400]]
    end
    it "should require a y coordinate" do
      lambda { @pdf.vertical_line(400,500) }.
        should.raise(ArgumentError)
    end
  end

end

describe "When drawing a polygon" do

  before(:each) { create_pdf }

  it "should draw each line passed to polygon()" do
    @pdf.polygon([100,500],[100,400],[200,400])

    line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
    line_drawing.points.should == [[100,500],[100,400],[200,400],[100,500]]
  end

end

describe "When drawing a rectangle" do

  before(:each) { create_pdf }

  it "should use a point, width, and height for coords" do
    @pdf.rectangle [200,200], 50, 100

    rectangles = PDF::Inspector::Graphics::Rectangle.
      analyze(@pdf.render).rectangles
    # PDF uses bottom left corner
    rectangles[0][:point].should  == [200,100]
    rectangles[0][:width].should  == 50
    rectangles[0][:height].should == 100

  end

end

describe "When drawing a curve" do

  before(:each) { create_pdf }

  it "should draw a bezier curve from 50,50 to 100,100" do
    @pdf.move_to  [50,50]
    @pdf.curve_to [100,100],:bounds => [[20,90], [90,70]]
    curve = PDF::Inspector::Graphics::Curve.analyze(@pdf.render)
    curve.coords.should == [50.0, 50.0, 20.0, 90.0, 90.0, 70.0, 100.0, 100.0]
  end

  it "should draw a bezier curve from 100,100 to 50,50" do
    @pdf.curve [100,100], [50,50], :bounds => [[20,90], [90,75]]
    curve = PDF::Inspector::Graphics::Curve.analyze(@pdf.render)
    curve.coords.should == [100.0, 100.0, 20.0, 90.0, 90.0, 75.0, 50.0, 50.0]
  end

end

describe "When drawing an ellipse" do
  before(:each) do
    create_pdf
    @pdf.ellipse_at [100,100], 25, 50
    @curve = PDF::Inspector::Graphics::Curve.analyze(@pdf.render)
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
    @curve = PDF::Inspector::Graphics::Curve.analyze(@pdf.render)
  end

  it "should stroke the same path as the equivalent ellipse" do
    middle = @curve.coords.length / 2
    @curve.coords[0...middle].should == @curve.coords[middle..-1]
  end
end

describe "When setting colors" do

  before(:each) { create_pdf }

  it "should set stroke colors" do
    @pdf.stroke_color "ffcccc"
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    # 100% red, 80% green, 80% blue
    colors.stroke_color.should == [1.0, 0.8, 0.8]
  end

  it "should set fill colors" do
    @pdf.fill_color "ccff00"
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    # 80% red, 100% green, 0% blue
    colors.fill_color.should == [0.8,1.0,0]
  end

  it "should reset the colors on each new page if they have been defined" do
    @pdf.fill_color "ccff00"
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)

    colors.fill_color_count.should == 2
    colors.stroke_color_count.should == 1
    @pdf.start_new_page
    @pdf.stroke_color "ff00cc"

    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    colors.fill_color_count.should == 3
    colors.stroke_color_count.should == 3

    @pdf.start_new_page
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
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
