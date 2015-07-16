# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "When drawing a line" do
  before(:each) { create_pdf }

  it "should draw a line from (100,600) to (100,500)" do
    @pdf.line([100, 600], [100, 500])

    line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)

    expect(line_drawing.points).to eq([[100, 600], [100, 500]])
  end

  it "should draw two lines at (100,600) to (100,500) " \
     "and (75,100) to (50,125)" do
    @pdf.line(100, 600, 100, 500)
    @pdf.line(75, 100, 50, 125)

    line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)

    expect(line_drawing.points).to eq(
      [[100.0, 600.0], [100.0, 500.0], [75.0, 100.0], [50.0, 125.0]]
    )
  end

  it "should properly set line width via line_width=" do
    @pdf.line_width = 10
    line = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
    expect(line.widths.first).to eq(10)
  end

  it "should properly set line width via line_width(width)" do
    @pdf.line_width(10)
    line = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
    expect(line.widths.first).to eq(10)
  end

  it "should carry the current line width settings over to new pages" do
    @pdf.line_width(10)
    @pdf.start_new_page
    line = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
    expect(line.widths.length).to eq(2)
    expect(line.widths[1]).to eq(10)
  end

  describe "(Horizontally)" do
    it "should draw from [x1,pdf.y],[x2,pdf.y]" do
      @pdf.horizontal_line(100, 150)
      @line = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
      expect(@line.points).to eq([[100.0 + @pdf.bounds.absolute_left, @pdf.y],
                                  [150.0 + @pdf.bounds.absolute_left, @pdf.y]])
    end

    it "should draw a line from (200, 250) to (300, 250)" do
      @pdf.horizontal_line(200, 300, :at => 250)
      line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
      expect(line_drawing.points).to eq([[200, 250], [300, 250]])
    end
  end

  describe "(Vertically)" do
    it "should draw a line from (350, 300) to (350, 400)" do
      @pdf.vertical_line(300, 400, :at => 350)
      line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
      expect(line_drawing.points).to eq([[350, 300], [350, 400]])
    end
    it "should require a y coordinate" do
      expect { @pdf.vertical_line(400, 500) }.
        to raise_error(ArgumentError)
    end
  end
end

describe "When drawing a polygon" do
  before(:each) { create_pdf }

  it "should draw each line passed to polygon()" do
    @pdf.polygon([100, 500], [100, 400], [200, 400])

    line_drawing = PDF::Inspector::Graphics::Line.analyze(@pdf.render)
    expect(line_drawing.points).to eq([[100, 500], [100, 400], [200, 400], [100, 500]])
  end
end

describe "When drawing a rectangle" do
  before(:each) { create_pdf }

  it "should use a point, width, and height for coords" do
    @pdf.rectangle [200, 200], 50, 100

    rectangles = PDF::Inspector::Graphics::Rectangle.analyze(@pdf.render).rectangles
    # PDF uses bottom left corner
    expect(rectangles[0][:point]).to eq([200, 100])
    expect(rectangles[0][:width]).to eq(50)
    expect(rectangles[0][:height]).to eq(100)
  end
end

describe "When drawing a curve" do
  before(:each) { create_pdf }

  it "should draw a bezier curve from 50,50 to 100,100" do
    @pdf.move_to [50, 50]
    @pdf.curve_to [100, 100], :bounds => [[20, 90], [90, 70]]
    curve = PDF::Inspector::Graphics::Curve.analyze(@pdf.render)
    expect(curve.coords).to eq([50.0, 50.0, 20.0, 90.0, 90.0, 70.0, 100.0, 100.0])
  end

  it "should draw a bezier curve from 100,100 to 50,50" do
    @pdf.curve [100, 100], [50, 50], :bounds => [[20, 90], [90, 75]]
    curve = PDF::Inspector::Graphics::Curve.analyze(@pdf.render)
    expect(curve.coords).to eq([100.0, 100.0, 20.0, 90.0, 90.0, 75.0, 50.0, 50.0])
  end
end

describe "When drawing a rounded rectangle" do
  before(:each) do
    create_pdf
    @pdf.rounded_rectangle([50, 550], 50, 100, 10)
    curve = PDF::Inspector::Graphics::Curve.analyze(@pdf.render)
    curve_points = []
    curve.coords.each_slice(2) { |p| curve_points << p }
    @original_point = curve_points.shift
    curves = []
    curve_points.each_slice(3) { |c| curves << c }
    line_points = PDF::Inspector::Graphics::Line.analyze(@pdf.render).points
    line_points.shift
    @all_coords = []
    line_points.zip(curves).flatten.each_slice(2) { |p| @all_coords << p }
    @all_coords.unshift @original_point
  end

  it "should draw a rectangle by connecting lines with rounded bezier curves" do
    expect(@all_coords).to eq([[60.0, 550.0], [90.0, 550.0], [95.5228, 550.0],
                               [100.0, 545.5228], [100.0, 540.0], [100.0, 460.0],
                               [100.0, 454.4772], [95.5228, 450.0], [90.0, 450.0],
                               [60.0, 450.0], [54.4772, 450.0], [50.0, 454.4772],
                               [50.0, 460.0], [50.0, 540.0], [50.0, 545.5228],
                               [54.4772, 550.0], [60.0, 550.0]])
  end

  it "should start and end with the same point" do
    expect(@original_point).to eq(@all_coords.last)
  end
end

describe "When drawing an ellipse" do
  before(:each) do
    create_pdf
    @pdf.ellipse [100, 100], 25, 50
    @curve = PDF::Inspector::Graphics::Curve.analyze(@pdf.render)
  end

  it "should use a Bézier approximation" do
    expect(@curve.coords).to eq(
      [125.0, 100.0,

       125.0, 127.6142,
       113.8071, 150,
       100.0, 150.0,

       86.1929, 150.0,
       75.0, 127.6142,
       75.0, 100.0,

       75.0, 72.3858,
       86.1929, 50.0,
       100.0, 50.0,

       113.8071, 50.0,
       125.0, 72.3858,
       125.0, 100.0,

       100.0, 100.0]
    )
  end

  it "should move the pointer to the center of the ellipse after drawing" do
    expect(@curve.coords[-2..-1]).to eq([100, 100])
  end
end

describe "When drawing a circle" do
  before(:each) do
    create_pdf
    @pdf.circle [100, 100], 25
    @pdf.ellipse [100, 100], 25, 25
    @curve = PDF::Inspector::Graphics::Curve.analyze(@pdf.render)
  end

  it "should stroke the same path as the equivalent ellipse" do
    middle = @curve.coords.length / 2
    expect(@curve.coords[0...middle]).to eq(@curve.coords[middle..-1])
  end
end

describe "When filling" do
  before(:each) { create_pdf }

  it "should default to the f operator (nonzero winding number rule)" do
    @pdf.renderer.expects(:add_content).with("f")
    @pdf.fill
  end

  it "should use f* for :fill_rule => :even_odd" do
    @pdf.renderer.expects(:add_content).with("f*")
    @pdf.fill(:fill_rule => :even_odd)
  end

  it "should use b by default for fill_and_stroke (nonzero winding number)" do
    @pdf.renderer.expects(:add_content).with("b")
    @pdf.fill_and_stroke
  end

  it "should use b* for fill_and_stroke(:fill_rule => :even_odd)" do
    @pdf.renderer.expects(:add_content).with("b*")
    @pdf.fill_and_stroke(:fill_rule => :even_odd)
  end
end

describe "When setting colors" do
  before(:each) { create_pdf }

  it "should set stroke colors" do
    @pdf.stroke_color "ffcccc"
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    # 100% red, 80% green, 80% blue
    expect(colors.stroke_color).to eq([1.0, 0.8, 0.8])
  end

  it "should set fill colors" do
    @pdf.fill_color "ccff00"
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    # 80% red, 100% green, 0% blue
    expect(colors.fill_color).to eq([0.8, 1.0, 0])
  end

  it "should reset the colors on each new page if they have been defined" do
    @pdf.fill_color "ccff00"

    @pdf.start_new_page
    @pdf.stroke_color "ff00cc"

    @pdf.start_new_page
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    expect(colors.fill_color_count).to eq(3)
    expect(colors.stroke_color_count).to eq(2)

    expect(colors.fill_color).to eq([0.8, 1.0, 0.0])
    expect(colors.stroke_color).to eq([1.0, 0.0, 0.8])
  end

  it "should set the color space when setting colors on new pages to please fussy readers" do
    @pdf.stroke_color "000000"
    @pdf.stroke { @pdf.rectangle([10, 10], 10, 10) }
    @pdf.start_new_page
    @pdf.stroke_color "000000"
    @pdf.stroke { @pdf.rectangle([10, 10], 10, 10) }
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    expect(colors.stroke_color_space_count[:DeviceRGB]).to eq(2)
  end
end

describe "Patterns" do
  before(:each) { create_pdf }

  describe 'linear gradients' do
    it "should create a /Pattern resource" do
      @pdf.fill_gradient [0, @pdf.bounds.height],
                         [@pdf.bounds.width, @pdf.bounds.height],
                         'FF0000', '0000FF'

      grad = PDF::Inspector::Graphics::Pattern.analyze(@pdf.render)
      pattern = grad.patterns.values.first

      expect(pattern).not_to be_nil
      expect(pattern[:Shading][:ShadingType]).to eq(2)
      expect(pattern[:Shading][:Coords]).to eq([0, 0, @pdf.bounds.width, 0])
      expect(pattern[:Shading][:Function][:C0].zip([1, 0, 0]).all?{ |x1, x2|
        (x1 - x2).abs < 0.01
      }).to be_true
      expect(pattern[:Shading][:Function][:C1].zip([0, 0, 1]).all?{ |x1, x2|
        (x1 - x2).abs < 0.01
      }).to be_true
    end

    it "fill_gradient should set fill color to the pattern" do
      @pdf.fill_gradient [0, @pdf.bounds.height],
                         [@pdf.bounds.width, @pdf.bounds.height],
                         'FF0000', '0000FF'

      str = @pdf.render
      expect(str).to match(%r{/Pattern\s+cs\s*/SP-?\d+\s+scn})
    end

    it "stroke_gradient should set stroke color to the pattern" do
      @pdf.stroke_gradient [0, @pdf.bounds.height],
                           [@pdf.bounds.width, @pdf.bounds.height],
                           'FF0000', '0000FF'

      str = @pdf.render
      expect(str).to match(%r{/Pattern\s+CS\s*/SP-?\d+\s+SCN})
    end
  end

  describe 'radial gradients' do
    it "should create a /Pattern resource" do
      @pdf.fill_gradient [0, @pdf.bounds.height], 10,
                         [@pdf.bounds.width, @pdf.bounds.height], 20,
                         'FF0000', '0000FF'

      grad = PDF::Inspector::Graphics::Pattern.analyze(@pdf.render)
      pattern = grad.patterns.values.first

      expect(pattern).not_to be_nil
      expect(pattern[:Shading][:ShadingType]).to eq(3)
      expect(pattern[:Shading][:Coords]).to eq([0, 0, 10, @pdf.bounds.width, 0, 20])
      expect(pattern[:Shading][:Function][:C0].zip([1, 0, 0]).all?{ |x1, x2|
        (x1 - x2).abs < 0.01
      }).to be_true
      expect(pattern[:Shading][:Function][:C1].zip([0, 0, 1]).all?{ |x1, x2|
        (x1 - x2).abs < 0.01
      }).to be_true
    end

    it "fill_gradient should set fill color to the pattern" do
      @pdf.fill_gradient [0, @pdf.bounds.height], 10,
                         [@pdf.bounds.width, @pdf.bounds.height], 20,
                         'FF0000', '0000FF'

      str = @pdf.render
      expect(str).to match(%r{/Pattern\s+cs\s*/SP-?\d+\s+scn})
    end

    it "stroke_gradient should set stroke color to the pattern" do
      @pdf.stroke_gradient [0, @pdf.bounds.height], 10,
                           [@pdf.bounds.width, @pdf.bounds.height], 20,
                           'FF0000', '0000FF'

      str = @pdf.render
      expect(str).to match(%r{/Pattern\s+CS\s*/SP-?\d+\s+SCN})
    end
  end
end

describe "When using painting shortcuts" do
  before(:each) { create_pdf }

  it "should convert stroke_some_method(args) into some_method(args); stroke" do
    @pdf.expects(:line_to).with([100, 100])
    @pdf.expects(:stroke)

    @pdf.stroke_line_to [100, 100]
  end

  it "should convert fill_some_method(args) into some_method(args); fill" do
    @pdf.expects(:line_to).with([100, 100])
    @pdf.expects(:fill)

    @pdf.fill_line_to [100, 100]
  end

  it "should not break method_missing" do
    expect { @pdf.i_have_a_pretty_girlfriend_named_jia }.
      to raise_error(NoMethodError)
  end
end

describe "When using graphics states" do
  before(:each) { create_pdf }

  it "should add the right content on save_graphics_state" do
    @pdf.renderer.expects(:add_content).with('q')

    @pdf.save_graphics_state
  end

  it "should add the right content on restore_graphics_state" do
    @pdf.renderer.expects(:add_content).with('Q')

    @pdf.restore_graphics_state
  end

  it "should save and restore when save_graphics_state is used with a block" do
    state = sequence "state"
    @pdf.renderer.expects(:add_content).with('q').in_sequence(state)
    @pdf.expects(:foo).in_sequence(state)
    @pdf.renderer.expects(:add_content).with('Q').in_sequence(state)

    @pdf.save_graphics_state do
      @pdf.foo
    end
  end

  it "should add the previous color space when restoring to a graphic state with different color space" do
    @pdf.stroke_color '000000'
    @pdf.save_graphics_state
    @pdf.stroke_color 0, 0, 0, 0
    @pdf.restore_graphics_state
    @pdf.stroke_color 0, 0, 100, 0
    expect(@pdf.graphic_state.color_space).to eq(:stroke => :DeviceCMYK)
    colors = PDF::Inspector::Graphics::Color.analyze(@pdf.render)
    expect(colors.color_space).to eq(:DeviceCMYK)
    expect(colors.stroke_color_space_count[:DeviceCMYK]).to eq(2)
  end

  it "should use the correct dash setting after restoring and starting new page" do
    @pdf.dash 5
    @pdf.save_graphics_state
    @pdf.dash 10
    expect(@pdf.graphic_state.dash[:dash]).to eq(10)
    @pdf.restore_graphics_state
    @pdf.start_new_page
    expect(@pdf.graphic_state.dash[:dash]).to eq(5)
  end

  it "should round dash values to four decimal places" do
    @pdf.dash 5.12345
    expect(@pdf.graphic_state.dash_setting).to eq("[5.1235 5.1235] 0.0 d")
  end

  it "should raise an error when dash is called w. a zero length or space" do
    expect { @pdf.dash(0) }.to raise_error(ArgumentError)
    expect { @pdf.dash([0]) }.to raise_error(ArgumentError)
    expect { @pdf.dash([0, 0]) }.to raise_error(ArgumentError)
    expect { @pdf.dash([0, 0, 0, 1]) }.to raise_error(ArgumentError)
  end

  it "the current graphic state should keep track of previous unchanged settings" do
    @pdf.stroke_color '000000'
    @pdf.save_graphics_state
    @pdf.dash 5
    @pdf.save_graphics_state
    @pdf.cap_style :round
    @pdf.save_graphics_state
    @pdf.fill_color 0, 0, 100, 0
    @pdf.save_graphics_state

    expect(@pdf.graphic_state.stroke_color).to eq("000000")
    expect(@pdf.graphic_state.join_style).to eq(:miter)
    expect(@pdf.graphic_state.fill_color).to eq([0, 0, 100, 0])
    expect(@pdf.graphic_state.cap_style).to eq(:round)
    expect(@pdf.graphic_state.color_space).to eq(:fill => :DeviceCMYK, :stroke => :DeviceRGB)
    expect(@pdf.graphic_state.dash).to eq(:space => 5, :phase => 0, :dash => 5)
    expect(@pdf.graphic_state.line_width).to eq(1)
  end

  it "should not add extra graphic space closings when rendering multiple times" do
    @pdf.render
    state = PDF::Inspector::Graphics::State.analyze(@pdf.render)
    expect(state.save_graphics_state_count).to eq(1)
    expect(state.restore_graphics_state_count).to eq(1)
  end

  it "should add extra graphic state enclosings when content is added on multiple renderings" do
    @pdf.render
    @pdf.text "Adding a bit more content"
    state = PDF::Inspector::Graphics::State.analyze(@pdf.render)
    expect(state.save_graphics_state_count).to eq(2)
    expect(state.restore_graphics_state_count).to eq(2)
  end

  it "adds extra graphic state enclosings when new settings are applied on multiple renderings" do
    @pdf.render
    @pdf.stroke_color 0, 0, 0, 0
    state = PDF::Inspector::Graphics::State.analyze(@pdf.render)
    expect(state.save_graphics_state_count).to eq(2)
    expect(state.restore_graphics_state_count).to eq(2)
  end

  it "should raise_error error if closing an empty graphic stack" do
    expect {
      @pdf.render
      @pdf.restore_graphics_state
    }.to raise_error(PDF::Core::Errors::EmptyGraphicStateStack)
  end

  it "should copy mutable attributes when passing a previous_state to the initializer" do
    new_state = PDF::Core::GraphicState.new(@pdf.graphic_state)

    [:color_space, :dash, :fill_color, :stroke_color].each do |attr|
      expect(new_state.send(attr)).to eq(@pdf.graphic_state.send(attr))
      expect(new_state.send(attr)).not_to equal(@pdf.graphic_state.send(attr))
    end
  end

  it "should copy mutable attributes when duping" do
    new_state = @pdf.graphic_state.dup

    [:color_space, :dash, :fill_color, :stroke_color].each do |attr|
      expect(new_state.send(attr)).to eq(@pdf.graphic_state.send(attr))
      expect(new_state.send(attr)).not_to equal(@pdf.graphic_state.send(attr))
    end
  end
end

describe "When using transformation matrix" do
  before(:each) { create_pdf }

  # Note: The (approximate) number of significant decimal digits of precision in fractional
  # part is 5 (PDF Reference, Third Edition, p. 706)

  it "should send the right content on transformation_matrix" do
    @pdf.renderer.expects(:add_content).with('1.00000 0.00000 0.12346 -1.00000 5.50000 20.00000 cm')
    @pdf.transformation_matrix 1, 0, 0.123456789, -1.0, 5.5, 20
  end

  it "should use fixed digits with very small number" do
    values = Array.new(6, 0.000000000001)
    string = Array.new(6, "0.00000").join " "
    @pdf.renderer.expects(:add_content).with("#{string} cm")
    @pdf.transformation_matrix(*values)
  end

  it "should be received by the inspector" do
    @pdf.transformation_matrix 1, 0, 0, -1, 5.5, 20
    matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
    expect(matrices.matrices).to eq([[1, 0, 0, -1, 5.5, 20]])
  end

  it "should save the graphics state inside the given block" do
    values = Array.new(6, 0.000000000001)
    string = Array.new(6, "0.00000").join " "
    process = sequence "process"

    @pdf.expects(:save_graphics_state).with.in_sequence(process)
    @pdf.renderer.expects(:add_content).with("#{string} cm").in_sequence(process)
    @pdf.expects(:do_something).with.in_sequence(process)
    @pdf.expects(:restore_graphics_state).with.in_sequence(process)
    @pdf.transformation_matrix(*values) do
      @pdf.do_something
    end
  end
end

describe "When using transformations shortcuts" do
  before(:each) do
    create_pdf
    @x, @y = 12, 54.32
    @angle = 12.32
    @cos = Math.cos(@angle * Math::PI / 180)
    @sin = Math.sin(@angle * Math::PI / 180)
    @factor = 0.12
  end

  describe "#rotate" do
    it "should rotate" do
      @pdf.expects(:transformation_matrix).with(@cos, @sin, -@sin, @cos, 0, 0)
      @pdf.rotate(@angle)
    end
  end

  describe "#rotate with :origin option" do
    it "should rotate around the origin" do
      x_prime = @x * @cos - @y * @sin
      y_prime = @x * @sin + @y * @cos

      @pdf.rotate(@angle, :origin => [@x, @y]) { @pdf.text('hello world') }

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      expect(matrices.matrices[0]).to eq([1, 0, 0, 1,
                                          reduce_precision(@x - x_prime),
                                          reduce_precision(@y - y_prime)])
      expect(matrices.matrices[1]).to eq([reduce_precision(@cos),
                                          reduce_precision(@sin),
                                          reduce_precision(-@sin),
                                          reduce_precision(@cos), 0, 0])
    end

    it "should rotate around the origin in a document with a margin" do
      @pdf = Prawn::Document.new

      @pdf.rotate(@angle, :origin => [@x, @y]) { @pdf.text('hello world') }

      x = @x + @pdf.bounds.absolute_left
      y = @y + @pdf.bounds.absolute_bottom
      x_prime = x * @cos - y * @sin
      y_prime = x * @sin + y * @cos

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      expect(matrices.matrices[0]).to eq([1, 0, 0, 1,
                                          reduce_precision(x - x_prime),
                                          reduce_precision(y - y_prime)])
      expect(matrices.matrices[1]).to eq([reduce_precision(@cos),
                                          reduce_precision(@sin),
                                          reduce_precision(-@sin),
                                          reduce_precision(@cos), 0, 0])
    end

    it "should raise_error BlockRequired if no block is given" do
      expect {
        @pdf.rotate(@angle, :origin => [@x, @y])
      }.to raise_error(Prawn::Errors::BlockRequired)
    end

    def reduce_precision(float)
      ("%.5f" % float).to_f
    end
  end

  describe "#translate" do
    it "should translate" do
      x, y = 12, 54.32
      @pdf.expects(:transformation_matrix).with(1, 0, 0, 1, x, y)
      @pdf.translate(x, y)
    end
  end

  describe "#scale" do
    it "should scale" do
      @pdf.expects(:transformation_matrix).with(@factor, 0, 0, @factor, 0, 0)
      @pdf.scale(@factor)
    end
  end

  describe "#scale with :origin option" do
    it "should scale from the origin" do
      x_prime = @factor * @x
      y_prime = @factor * @y

      @pdf.scale(@factor, :origin => [@x, @y]) { @pdf.text('hello world') }

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      expect(matrices.matrices[0]).to eq([1, 0, 0, 1,
                                          reduce_precision(@x - x_prime),
                                          reduce_precision(@y - y_prime)])
      expect(matrices.matrices[1]).to eq([@factor, 0, 0, @factor, 0, 0])
    end

    it "should scale from the origin in a document with a margin" do
      @pdf = Prawn::Document.new
      x = @x + @pdf.bounds.absolute_left
      y = @y + @pdf.bounds.absolute_bottom
      x_prime = @factor * x
      y_prime = @factor * y

      @pdf.scale(@factor, :origin => [@x, @y]) { @pdf.text('hello world') }

      matrices = PDF::Inspector::Graphics::Matrix.analyze(@pdf.render)
      expect(matrices.matrices[0]).to eq([1, 0, 0, 1,
                                          reduce_precision(x - x_prime),
                                          reduce_precision(y - y_prime)])
      expect(matrices.matrices[1]).to eq([@factor, 0, 0, @factor, 0, 0])
    end

    it "should raise_error BlockRequired if no block is given" do
      expect {
        @pdf.scale(@factor, :origin => [@x, @y])
      }.to raise_error(Prawn::Errors::BlockRequired)
    end

    def reduce_precision(float)
      ("%.5f" % float).to_f
    end
  end

  # describe "skew" do
  #   it "should skew" do
  #     a, b = 30, 50.2
  #     @pdf.expects(:transformation_matrix).with(1, Math.tan(a * Math::PI / 180), Math.tan(b * Math::PI / 180), 1, 0, 0)
  #     @pdf.skew(a, b)
  #   end
  # end
end
