# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

module CellHelpers

  # Build, but do not draw, a cell on @pdf.
  # TODO: differentiate class based on :content.
  def cell(options={})
    at = options[:at] || [0, @pdf.cursor]
    Prawn::Table::Cell::Text.new(@pdf, at, options)
  end

  def close?(actual, expected, epsilon=0.01)
    (actual - expected).abs < epsilon
  end

end

describe "Prawn::Table::Cell" do
  before(:each) do
    @pdf = Prawn::Document.new
  end

  describe "Prawn::Document#cell" do
    include CellHelpers

    it "should draw the cell" do
      Prawn::Table::Cell::Text.any_instance.expects(:draw).once
      @pdf.cell(:content => "text")
    end

    it "should return a Cell" do
      @pdf.cell(:content => "text").should.be.a.kind_of Prawn::Table::Cell
    end

    it "should draw text at the given point plus padding, with the given " +
       "size and style" do
      @pdf.expects(:bounding_box).yields
      @pdf.expects(:move_down)
      @pdf.expects(:draw_text!).with { |text, options| text == "hello world" }

      @pdf.cell(:content => "hello world", 
                :at => [10, 20],
                :padding => [30, 40],
                :size => 7, 
                :style => :bold)
    end
  end

  describe "cell width" do
    include CellHelpers

    it "should be calculated for text" do
      c = cell(:content => "text")
      c.width.should == @pdf.width_of("text") + c.padding[1] + c.padding[3]
    end

    it "should be overridden by manual :width" do
      c = cell(:content => "text", :width => 400)
      c.width.should == 400
    end

    it "should incorporate padding when specified" do
      c = cell(:content => "text", :padding => [1, 2, 3, 4])
      c.width.should.be.close(@pdf.width_of("text") + 6, 0.01)
    end

    it "should allow width to be reset after it has been calculated" do
      # to ensure that if we memoize width, it can still be overridden
      c = cell(:content => "text")
      c.width
      c.width = 400
      c.width.should == 400
    end

    it "should return proper width with size set" do
      text = "text " * 4
      c = cell(:content => text, :size => 7)
      c.width.should == 
        @pdf.width_of(text, :size => 7) + c.padding[1] + c.padding[3]
    end

    it "content_width should exclude padding" do
      c = cell(:content => "text", :padding => 10)
      c.content_width.should == @pdf.width_of("text")
    end

    it "content_width should exclude padding even with manual :width" do
      c = cell(:content => "text", :padding => 10, :width => 400)
      c.content_width.should.be.close(380, 0.01)
    end

    it "should have a reasonable minimum width that can fit @content" do
      c = cell(:content => "text", :padding => 10)
      min_content_width = c.min_width - c.padding[1] - c.padding[3]

      lambda { @pdf.height_of("text", :width => min_content_width) }.
        should.not.raise(Prawn::Errors::CannotFit)

      @pdf.height_of("text", :width => min_content_width).should.be <
        (5 * @pdf.height_of("text"))
    end

  end

  describe "cell height" do
    include CellHelpers

    it "should be calculated for text" do
      c = cell(:content => "text")
      c.height.should == 
        @pdf.height_of("text", :width => @pdf.width_of("text")) +
        c.padding[0] + c.padding[3]
    end

    it "should be overridden by manual :height" do
      c = cell(:content => "text", :height => 400)
      c.height.should == 400
    end

    it "should incorporate :padding when specified" do
      c = cell(:content => "text", :padding => [1, 2, 3, 4])
      c.height.should.be.close(1 + 3 +
        @pdf.height_of("text", :width => @pdf.width_of("text")), 0.01)
    end

    it "should allow height to be reset after it has been calculated" do
      # to ensure that if we memoize height, it can still be overridden
      c = cell(:content => "text")
      c.height
      c.height = 400
      c.height.should == 400
    end

    it "should return proper height for blocks of text" do
      content = "words " * 10
      c = cell(:content => content, :width => 100)
      c.height.should == @pdf.height_of(content, :width => 100) +
        c.padding[0] + c.padding[2]
    end

    it "should return proper height for blocks of text with size set" do
      content = "words " * 10
      c = cell(:content => content, :width => 100, :size => 7)

      correct_content_height = nil
      @pdf.font_size(7) do
        correct_content_height = @pdf.height_of(content, :width => 100)
      end

      c.height.should == correct_content_height + c.padding[0] + c.padding[2]
    end

    it "content_height should exclude padding" do
      c = cell(:content => "text", :padding => 10)
      c.content_height.should == @pdf.height_of("text")
    end
    
    it "content_height should exclude padding even with manual :height" do
      c = cell(:content => "text", :padding => 10, :height => 400)
      c.content_height.should.be.close(380, 0.01)
    end
  end

  describe "cell padding" do
    include CellHelpers

    it "should default to zero" do
      c = cell(:content => "text")
      c.padding.should == [5, 5, 5, 5]
    end

    it "should accept a numeric value, setting all padding" do
      c = cell(:content => "text", :padding => 10)
      c.padding.should == [10, 10, 10, 10]
    end

    it "should accept [v,h]" do
      c = cell(:content => "text", :padding => [20, 30])
      c.padding.should == [20, 30, 20, 30]
    end

    it "should accept [t,l,b,r]" do
      c = cell(:content => "text", :padding => [10, 20, 30, 40])
      c.padding.should == [10, 20, 30, 40]
    end

    it "should reject other formats" do
      lambda{
        cell(:content => "text", :padding => [10])
      }.should.raise(ArgumentError)
    end
  end

  describe "background_color" do
    include CellHelpers

    it "should fill a rectangle with the given background color" do
      @pdf.stubs(:mask).yields
      @pdf.expects(:mask).with(:fill_color).yields

      @pdf.stubs(:fill_color)
      @pdf.expects(:fill_color).with('123456')
      @pdf.expects(:fill_rectangle).with do |(x, y), w, h|
        close?(x, 0) && close?(y, @pdf.cursor) && 
          close?(w, 29.344) && close?(h, 23.872)
      end
      @pdf.cell(:content => "text", :background_color => '123456')
    end
  end

  describe "color" do
    it "should set fill color when :text_color is provided" do
      pdf = Prawn::Document.new
      pdf.stubs(:fill_color)
      pdf.expects(:fill_color).with('555555')
      pdf.cell :content => 'foo', :text_color => '555555'
    end

    it "should reset the fill color to the original one" do
      pdf = Prawn::Document.new
      pdf.fill_color = '333333'
      pdf.cell :content => 'foo', :text_color => '555555'
      pdf.fill_color.should == '333333'
    end
  end

  describe "Borders" do
    it "should draw all borders by default" do
      @pdf.expects(:stroke_line).times(4)
      @pdf.cell(:content => "text")
    end

    it "should draw all borders when requested" do
      @pdf.expects(:stroke_line).times(4)
      @pdf.cell(:content => "text", :borders => [:top, :right, :bottom, :left])
    end

    # Only roughly verifying the integer coordinates so that we don't have to
    # do any FP closeness arithmetic. Can plug in that math later if this goes
    # wrong.
    it "should draw top border when requested" do
      @pdf.expects(:stroke_line).with { |*from_and_to|
        #                                  from: x  y to: x  y
        from_and_to.flatten.map{|x| x.round} == [0, 720, 29, 720]
      }
      @pdf.cell(:content => "text", :borders => [:top])
    end

    it "should draw bottom border when requested" do
      @pdf.expects(:stroke_line).with { |*from_and_to|
        from_and_to.flatten.map{|x| x.round} == [0, 696, 29, 696]
      }
      @pdf.cell(:content => "text", :borders => [:bottom])
    end

    it "should draw left border when requested" do
      @pdf.expects(:stroke_line).with { |*from_and_to|
        from_and_to.flatten.map{|x| x.round} == [0, 721, 0, 696]
      }
      @pdf.cell(:content => "text", :borders => [:left])
    end

    it "should draw right border when requested" do
      @pdf.expects(:stroke_line).with { |*from_and_to|
        from_and_to.flatten.map{|x| x.round} == [29, 721, 29, 696]
      }
      @pdf.cell(:content => "text", :borders => [:right])
    end
  end

  describe "Text cell attributes" do
    include CellHelpers

    it "should pass through text options like :align to Text::Box" do
      c = cell(:content => "text", :align => :right)

      box = Prawn::Text::Box.new("text", :document => @pdf)

      Prawn::Text::Box.expects(:new).with do |text, options|
        text == "text" && options[:align] == :right
      end.at_least_once.returns(box)

      c.draw
    end

    it "should allow inline formatting in cells" do
      c = cell(:content => "foo <b>bar</b> baz", :inline_format => true)

      box = Prawn::Text::Formatted::Box.new([], :document => @pdf)

      Prawn::Text::Formatted::Box.expects(:new).with do |array, options|
        array[0][:text] == "foo " && array[0][:styles] == [] &&
          array[1][:text] == "bar" && array[1][:styles] == [:bold] &&
          array[2][:text] == " baz" && array[2][:styles] == []
      end.at_least_once.returns(box)

      c.draw
    end

  end

  describe "Font handling" do
    include CellHelpers

    it "should allow only :style to be specified, defaulting to the" +
       "document's font" do
      c = cell(:content => "text", :style => :bold)
      c.font.name.should == 'Helvetica-Bold'
    end

    it "should accept a font name for :font" do
      c = cell(:content => "text", :font => 'Helvetica-Bold')
      c.font.name.should == 'Helvetica-Bold'
    end

    it "should allow style to be changed after initialize" do
      c = cell(:content => "text")
      c.style = :bold
      c.font.name.should == 'Helvetica-Bold'
    end

    it "should default to the document's font, if none is specified" do
      c = cell(:content => "text")
      c.font.should == @pdf.font
    end

    it "should use the metrics of the selected font (even if it is a variant " +
       "of the document's font) to calculate width" do
      c = cell(:content => "text", :style => :bold)
      font = @pdf.find_font('Helvetica-Bold')
      c.content_width.should == font.compute_width_of("text")
    end
  end

end
