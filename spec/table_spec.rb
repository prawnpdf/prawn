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

end

