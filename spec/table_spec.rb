# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  
require 'set'

describe "Prawn::Table" do

  describe "converting data to Cell objects" do
    before(:each) do
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

    it "should allow empty fields" do
      lambda {
        data = [["foo","bar"],["baz",""]]
        @pdf.table(data)
      }.should.not.raise
    end   

    # TODO: pending colspan
    xit "should accurately count columns from data" do
      # First data row may contain colspan which would hide true column count
      data = [["Name:",{:text => "Some very long name", :colspan => 5}]]
      pdf = Prawn::Document.new
      table = Prawn::Table.new data, pdf
      table.column_widths.length.should == 6
    end
  end

  describe "#initialize" do
    before(:each) do
      @pdf = Prawn::Document.new
    end

    it "should instance_eval a 0-arg block" do
      initializer = mock()
      initializer.expects(:kick).once

      @pdf.table([["a"]]){
        self.should.be.an.instance_of(Prawn::Table); initializer.kick }
    end

    it "should call a 1-arg block with the document as the argument" do
      initializer = mock()
      initializer.expects(:kick).once

      @pdf.table([["a"]]){ |doc|
        doc.should.be.an.instance_of(Prawn::Table); initializer.kick }
    end

    it "should proxy cell methods to #cells" do
      table = @pdf.table([["a"]], :cell_style => { :padding => 11 })
      table.cells[0, 0].padding.should == [11, 11, 11, 11]
    end

    it "should set row and column length" do
      table = @pdf.table([["a", "b", "c"], ["d", "e", "f"]])
      table.row_length.should == 2
      table.column_length.should == 3
    end

    it "should generate a text cell based on a String" do
      t = @pdf.table([["foo"]])
      t.cells[0,0].should.be.a.kind_of(Prawn::Table::Cell::Text)
    end

    it "should pass through a text cell" do
      c = Prawn::Table::Cell::Text.new(@pdf, [0,0], :content => "foo")
      t = @pdf.table([[c]])
      t.cells[0,0].should == c
    end
  end

  describe "cell accessors" do
    before(:each) do
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
    before(:each) do
      @pdf = Prawn::Document.new
      @long_text = "The quick brown fox jumped over the lazy dogs. " * 5
    end

    describe "width" do
      it "should raise an error if the given width is outside of range" do
        lambda do
          @pdf.table([["foo"]], :width => 1)
        end.should.raise(Prawn::Errors::CannotFit)

        lambda do
          @pdf.table([[@long_text]], :width => @pdf.bounds.width + 100)
        end.should.raise(Prawn::Errors::CannotFit)
      end

      it "should accept the natural width for small tables" do
        pad = 10 # default padding
        @table = @pdf.table([["a"]])
        @table.width.should == @table.cells[0, 0].natural_content_width + pad
      end

      it "width should equal sum(column_widths)" do
        table = Prawn::Table.new([%w[ a b c ], %w[d e f]], @pdf) do
          column(0).width = 50
          column(1).width = 100
          column(2).width = 150
        end
        table.width.should == 300
      end

      it "should calculate unspecified column widths as "+
         "(max(string_width) + 2*horizontal_padding)" do
        hpad, fs = 3, 12
        columns = 2
        table = Prawn::Table.new( [%w[ foo b ], %w[d foobar]], @pdf,
          :cell_style => { :padding => hpad, :size => fs } )

        col0_width = @pdf.width_of("foo", :size => fs)
        col1_width = @pdf.width_of("foobar", :size => fs)

        table.width.should == col0_width + col1_width + 2*columns*hpad
      end

      it "should allow mixing autocalculated and preset"+
         "column widths within a single table" do
        hpad, fs = 10, 6
        stretchy_columns = 2
        
        col0_width = 50
        col1_width = @pdf.width_of("foo", :size => fs)
        col2_width = @pdf.width_of("foobar", :size => fs)
        col3_width = 150

        table = Prawn::Table.new( [%w[snake foo b apple], 
                                   %w[kitten d foobar banana]], @pdf,
          :cell_style => { :padding => hpad, :size => fs }) do

          column(0).width = col0_width
          column(3).width = col3_width
        end

        table.width.should == col1_width + col2_width + 
                              2*stretchy_columns*hpad + 
                              col0_width + col3_width
      end

      it "should not exceed the maximum width of the margin_box" do
        expected_width = @pdf.margin_box.width
        data = [
          ['This is a column with a lot of text that should comfortably exceed '+
          'the width of a normal document margin_box width', 'Some more text', 
          'and then some more', 'Just a bit more to be extra sure']
        ]
        table = Prawn::Table.new(data, @pdf)

        table.width.should == expected_width
      end

      it "should not exceed the maximum width of the margin_box even with" +
        "manual widths specified" do
        expected_width = @pdf.margin_box.width
        data = [
          ['This is a column with a lot of text that should comfortably exceed '+
          'the width of a normal document margin_box width', 'Some more text', 
          'and then some more', 'Just a bit more to be extra sure']
        ]
        table = Prawn::Table.new(data, @pdf) { column(1).width = 100 }

        table.width.should == expected_width
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

      it "should respect manual widths" do
        @table = @pdf.table([%w[foo bar baz], %w[baz bar foo]], :width => 500) do
          column(1).width = 60
        end
        @table.column(1).width.should == 60
        @table.column(0).width.should == @table.column(2).width
      end

      it "should be the width of the :width parameter" do
        expected_width = 300
        table = Prawn::Table.new( [%w[snake foo b apple], 
                                   %w[kitten d foobar banana]], @pdf,
                                 :width => expected_width)

        table.width.should == expected_width
      end

      it "should not exceed the :width option" do
        expected_width = 400
        data = [
          ['This is a column with a lot of text that should comfortably exceed '+
          'the width of a normal document margin_box width', 'Some more text', 
          'and then some more', 'Just a bit more to be extra sure']
        ]
        table = Prawn::Table.new(data, @pdf, :width => expected_width)

        table.width.should == expected_width
      end

      it "should not exceed the :width option even with manual widths specified" do
        expected_width = 400
        data = [
          ['This is a column with a lot of text that should comfortably exceed '+
          'the width of a normal document margin_box width', 'Some more text', 
          'and then some more', 'Just a bit more to be extra sure']
        ]
        table = Prawn::Table.new(data, @pdf, :width => expected_width) do
          column(1).width = 100
        end

        table.width.should == expected_width
      end

      # TODO: pending colspan
      xit "should calculate unspecified column widths even " +
         "with colspan cells declared" do
        pdf = Prawn::Document.new
        hpad, fs = 3, 5
        columns  = 3

        data = [ [ { :text => 'foo', :colspan => 2 }, "foobar" ],
                 [ "foo", "foo", "foo" ] ]
        table = Prawn::Table.new( data, pdf,
          :horizontal_padding => hpad,
          :font_size => fs )

        col0_width = pdf.width_of("foo",    :size => fs) # cell 1, 0
        col1_width = pdf.width_of("foo",    :size => fs) # cell 1, 1
        col2_width = pdf.width_of("foobar", :size => fs) # cell 0, 1 (at col 2)

        table.width.should == col0_width.ceil + col1_width.ceil +
                              col2_width.ceil + 2*columns*hpad
      end
    end

    describe "height" do
      it "should set all cells in a row to the same height" do
        @table = @pdf.table([["foo", @long_text]])
        @table.cells[0, 0].height.should == @table.cells[0, 1].height
      end

      it "should move y-position to the bottom of the table after drawing" do
        old_y = @pdf.y
        table = @pdf.table([["foo"]])
        @pdf.y.should == old_y - table.height
      end

      it "should not wrap unnecessarily" do
        # Test for FP errors and glitches
        t = @pdf.table([["Bender Bending Rodriguez"]])
        h = @pdf.height_of("one line")
        (t.height - 10).should.be < h*1.5
      end

      it "should have a height of n rows" do  
        data = [["foo"],["bar"],["baaaz"]]
           
        vpad = 4
        origin = @pdf.y
        @pdf.table data, :cell_style => { :padding => vpad }

        table_height = origin - @pdf.y
        font_height = @pdf.font.height

        num_rows = data.length
        table_height.should.be.close(
          num_rows*font_height + 2*vpad*num_rows, 0.001 )
      end

    end

  end

  describe "Multi-page tables" do
    it "should flow to the next page when hitting the bottom of the bounds" do
      Prawn::Document.new { table([["foo"]] * 30) }.page_count.should == 1
      Prawn::Document.new { table([["foo"]] * 31) }.page_count.should == 2
      Prawn::Document.new { table([["foo"]] * 31); table([["foo"]] * 31) }.
        page_count.should == 3
    end

    it "should respect the containing bounds" do
      Prawn::Document.new do
        bounding_box([0, cursor], :width => bounds.width, :height => 72) do
          table([["foo"]] * 4)
        end
      end.page_count.should == 2
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

  describe "row_colors" do
    it "should allow array syntax for :row_colors" do
      data = [["foo"], ["bar"], ["baz"]]
      pdf = Prawn::Document.new
      t = pdf.table(data, :row_colors => ['cccccc', 'ffffff'])
      t.cells.map{|x| x.background_color}.should == %w[cccccc ffffff cccccc]
    end

    it "should ignore headers" do
      data = [["header"], ["foo"], ["bar"], ["baz"]]
      pdf = Prawn::Document.new
      t = pdf.table(data, :header => true, 
                    :row_colors => ['cccccc', 'ffffff']) do
        row(0).background_color = '333333'
      end

      t.cells.map{|x| x.background_color}.should == 
        %w[333333 cccccc ffffff cccccc]
    end
  end

  describe "inking" do
    before(:each) do
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
      y = 0
      @table = @pdf.make_table([["foo"], ["bar"], ["baz"]])

      (0..2).each do |row|
        cell = @table.cells[row, 0]
        cell.y.should.be.close(y, 0.01)
        y -= cell.height
      end
    end

    it "should output content cell by cell, row by row" do
      data = [["foo","bar"],["baz","bang"]]
      @pdf = Prawn::Document.new
      @pdf.table(data)
      output = PDF::Inspector::Text.analyze(@pdf.render)
      output.strings.should == data.flatten
    end

    it "should not cause an error if rendering the very first row causes a " +
      "page break" do
      Prawn::Document.new do
        arr = Array(1..5).collect{|i| ["cell #{i}"] }

        move_down( y - (bounds.absolute_bottom + 3) )

        lambda {
          table(arr)
        }.should.not.raise
      end
    end

    it "should allow multiple inkings of the same table" do
      pdf = Prawn::Document.new
      t = Prawn::Table.new([["foo"]], pdf)

      pdf.expects(:bounding_box).with{|(x, y), options| y.to_i == 495}.yields
      pdf.expects(:bounding_box).with{|(x, y), options| y.to_i == 395}.yields
      pdf.expects(:draw_text!).with{ |text, options| text == 'foo' }.twice

      pdf.move_cursor_to(500)
      t.draw

      pdf.move_cursor_to(400)
      t.draw
    end
  end

  describe "headers" do
    it "should add headers to output when specified" do
      data = [["a", "b"], ["foo","bar"],["baz","bang"]]
      @pdf = Prawn::Document.new
      @pdf.table(data, :header => true)
      output = PDF::Inspector::Text.analyze(@pdf.render)   
      output.strings.should == data.flatten
    end

    it "should repeat headers across pages" do
      data = [["foo","bar"]]*30
      headers = ["baz","foobar"]
      @pdf = Prawn::Document.new
      @pdf.table([headers] + data, :header => true)
      output = PDF::Inspector::Text.analyze(@pdf.render)   
      output.strings.should == headers + data.flatten[0..-3] + headers +
        data.flatten[-2..-1]
    end
  end

  describe "nested tables" do
    before(:each) do
      @pdf = Prawn::Document.new
      @subtable = Prawn::Table.new([["foo"]], @pdf)
      @table = @pdf.table([[@subtable, "bar"]])
    end

    it "can be created from an Array" do
      cell = Prawn::Table::Cell.make(@pdf, [["foo"]])
      cell.should.be.an.instance_of(Prawn::Table::Cell::Subtable)
      cell.subtable.should.be.an.instance_of(Prawn::Table)
    end

    it "defaults its padding to zero" do
      @table.cells[0, 0].padding.should == [0, 0, 0, 0]
    end

    it "has a subtable accessor" do
      @table.cells[0, 0].subtable.should == @subtable
    end
    
    it "determines its dimensions from the subtable" do
      @table.cells[0, 0].width.should == @subtable.width
      @table.cells[0, 0].height.should == @subtable.height
    end

  end

  describe "An invalid table" do
    
    before(:each) do
      @pdf = Prawn::Document.new
      @bad_data = ["Single Nested Array"]
    end
    
    it "should raise error when invalid table data is given" do
      assert_raises(Prawn::Errors::InvalidTableData) do
        @pdf.table(@bad_data)
      end
    end

    it "should raise an EmptyTableError with empty table data" do
      lambda {
        data = []
        @pdf = Prawn::Document.new
        @pdf.table(data)
      }.should.raise( Prawn::Errors::EmptyTable )
    end   

    it "should raise an EmptyTableError with nil table data" do
      lambda {
        data = nil
        @pdf = Prawn::Document.new
        @pdf.table(data)
      }.should.raise( Prawn::Errors::EmptyTable )
    end   

  end

end

