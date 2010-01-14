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

  describe "#initialize" do
    it "should instance_eval a 0-arg block" do
      pdf = Prawn::Document.new
      initializer = mock()
      initializer.expects(:kick).once

      pdf.table([["a"]]){
        self.should.be.an.instance_of(Prawn::Table); initializer.kick }
    end

    it "should call a 1-arg block with the document as the argument" do
      pdf = Prawn::Document.new
      initializer = mock()
      initializer.expects(:kick).once

      pdf.table([["a"]]){ |doc|
        doc.should.be.an.instance_of(Prawn::Table); initializer.kick }
    end

    it "should proxy cell methods to #cells" do
      pdf = Prawn::Document.new
      table = pdf.table([["a"]], :cell_style => { :padding => 11 })
      table.cells[0, 0].padding.should == [11, 11, 11, 11]
    end

    it "should set row and column length" do
      pdf = Prawn::Document.new
      table = pdf.table([["a", "b", "c"], ["d", "e", "f"]])
      table.row_length.should == 2
      table.column_length.should == 3
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

    it "should return the width of selected columns for #width" do
      c0_width = @table.column(0).map{ |c| c.width }.max
      c1_width = @table.column(1).map{ |c| c.width }.max

      @table.column(0).width.should == c0_width
      @table.column(1).width.should == c1_width

      @table.columns(0..1).width.should == c0_width + c1_width
      @table.cells.width.should == c0_width + c1_width
    end

    it "should return the height of selected rows for #height" do
      r0_height = @table.row(0).map{ |c| c.height }.max
      r1_height = @table.row(1).map{ |c| c.height }.max

      @table.row(0).height.should == r0_height
      @table.row(1).height.should == r1_height

      @table.rows(0..1).height.should == r0_height + r1_height
      @table.cells.height.should == r0_height + r1_height
    end
  end

  describe "layout" do
    setup do
      @pdf = Prawn::Document.new
      @long_text = "The quick brown fox jumped over the lazy dogs. " * 5
    end

    it "should accept the natural width for small tables" do
      pad = 10 # default padding
      @table = @pdf.table([["a"]])
      @table.width.should == @table.cells[0, 0].natural_content_width + pad
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

    it "should shrink columns evenly when two equal columns compete" do
      @table = @pdf.table([["foo", @long_text], [@long_text, "foo"]])
      @table.cells[0, 0].width.should == @table.cells[0, 1].width
    end

    it "should grow columns evenly when equal deficient columns compete" do
      @table = @pdf.table([["foo", "foobar"], ["foobar", "foo"]], :width => 500)
      @table.cells[0, 0].width.should == @table.cells[0, 1].width
    end

# TODO: this is a bad spec
#     it "should set all cells in a row to the same height" do
#       @table = @pdf.table([["foo", @long_text]])
#       @table.cells[0, 0].height.should == @table.cells[0, 1].height
#     end

    it "should move y-position to the bottom of the table after drawing" do
      old_y = @pdf.y
      table = @pdf.table([["foo"]])
      @pdf.y.should == old_y - table.height
    end
  end

  describe "#style" do
    it "should send #style to its first argument, passing the style hash and" +
        " block" do

      stylable = stub()
      stylable.expects(:style).with(:foo => :bar).once.yields

      block = stub()
      block.expects(:kick).once

      Prawn::Document.new do
        table([["x"]]) { style(stylable, :foo => :bar) { block.kick } }
      end
    end

    it "should default to {} for the hash argument" do
      stylable = stub()
      stylable.expects(:style).with({}).once
      
      Prawn::Document.new do
        table([["x"]]) { style(stylable) }
      end
    end
  end

  describe "inking" do
    setup do
      @pdf = Prawn::Document.new
    end

    it "should set the x-position of each cell based on widths" do
      @table = @pdf.table([["foo", "bar", "baz"]])
      
      x = 0
      (0..2).each do |col|
        cell = @table.cells[0, col]
        cell.x.should == x
        x += cell.width
      end
    end

    it "should set the y-position of each cell based on heights" do
      y = @pdf.cursor
      @table = @pdf.table([["foo"], ["bar"], ["baz"]])

      (0..2).each do |row|
        cell = @table.cells[row, 0]
        cell.y.should == y
        y -= cell.height
      end
    end
  end

end

