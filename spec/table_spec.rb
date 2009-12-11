# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

module CellHelpers

  # Build, but do not draw, a cell on @pdf.
  def cell(options={})
    at = options[:at] || [0, @pdf.cursor]
    Prawn::Table::Cell.new(@pdf, at, options)
  end

end

describe "Prawn::Table::Cell" do
  before(:each) do
    @pdf = Prawn::Document.new
  end

  describe "Prawn::Document#cell" do
    it "should draw the cell" do
      Prawn::Table::Cell.any_instance.expects(:draw).once
      @pdf.cell(:content => "text")
    end

    it "should return a Cell" do
      @pdf.cell(:content => "text").should.be.an.instance_of Prawn::Table::Cell
    end
  end

  describe "cell width" do
    include CellHelpers

    it "should be calculated for text" do
      c = cell(:content => "text")
      c.width.should == @pdf.width_of("text")
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

    # TODO: font_size

    it "content_width should exclude padding" do
      c = cell(:content => "text", :padding => 10)
      c.content_width.should == @pdf.width_of("text")
    end

    it "content_width should exclude padding even with manual :width" do
      c = cell(:content => "text", :padding => 10, :width => 400)
      c.content_width.should.be.close(380, 0.01)
    end

  end

  describe "cell height" do
    include CellHelpers

    it "should be calculated for text" do
      c = cell(:content => "text")
      c.height.should == @pdf.height_of("text", :width => @pdf.width_of("text"))
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

    # TODO: font_size

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
      c.padding.should == [0, 0, 0, 0]
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

end
