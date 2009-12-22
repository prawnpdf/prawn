# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  
require 'set'

describe "Prawn::Table" do

  describe "converting data to Cell objects" do
    setup do
      @pdf = Prawn::Document.new
      @table = @pdf.table([%w[R0C0 R0C1], %w[R1C0 R1C1]])
    end

    it "should return a Prawn::Table" do
      @table.should.be.an.instance_of Prawn::Table
    end

    it "should flatten the data into the @cells array in row-major order" do
      @table.cells.map { |c| c.content }.should == %w[R0C0 R0C1 R1C0 R1C1]
    end

    it "should add row and column numbers to each cell" do
      c = @table.cells.to_a.first
      c.row.should == 0
      c.column.should == 0
    end
  end

  describe "cell accessors" do
    setup do
      @pdf = Prawn::Document.new
      @table = @pdf.table([%w[R0C0 R0C1], %w[R1C0 R1C1]])
    end

    it "should select rows by number or range" do
      Set.new(@table.row(0).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R0C1])
      Set.new(@table.rows(0..1).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R0C1 R1C0 R1C1])
    end

    it "should select columns by number or range" do
      Set.new(@table.column(0).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R1C0])
      Set.new(@table.columns(0..1).map { |c| c.content }).should == 
        Set.new(%w[R0C0 R0C1 R1C0 R1C1])
    end

    it "should allow rows and columns to be combined" do
      @table.row(0).column(1).map { |c| c.content }.should == ["R0C1"]
    end

    it "should accept a select block, returning a cell proxy" do
      @table.cells.select { |c| c.content =~ /R0/ }.column(1).map{ |c| 
        c.content }.should == ["R0C1"]
    end

    it "should accept the [] method, returning a Cell or nil" do
      @table.cells[0, 0].content.should == "R0C0"
      @table.cells[12, 12].should.be.nil
    end

    it "should proxy unknown methods to the cells" do
      @table.cells.height = 200
      @table.row(1).height = 100

      @table.cells[0, 0].height.should == 200
      @table.cells[1, 0].height.should == 100
    end

    it "should accept the style method, proxying its calls to the cells" do
      @table.cells.style(:height => 200, :width => 200)
      @table.column(0).style(:width => 100)

      @table.cells[0, 1].width.should == 200
      @table.cells[1, 0].height.should == 200
      @table.cells[1, 0].width.should == 100
    end
  end

  describe "layout" do
    setup do
      @pdf = Prawn::Document.new
      @long_text = "The quick brown fox jumped over the lazy dogs. " * 30
    end

    it "should accept the natural width for small tables" do
      @table = @pdf.table([["a"]])
      @table.width.should == @table.cells[0, 0].natural_content_width
    end

    it "should limit tables to the width of the page by default" do
      @table = @pdf.table([[@long_text]])
      @table.width.should == @pdf.bounds.width
    end

    it "should accept manual values for table width, even beyond page bounds" do
      width = @pdf.bounds.width + 100
      @table = @pdf.table([[@long_text]], :width => width)
      @table.width.should == width
    end

    it "should allow width to be reset even after it has been calculated" do
      @table = @pdf.table([[@long_text]])
      @table.width
      @table.width = 100
      @table.width.should == 100
    end
  end

end

