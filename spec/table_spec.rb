# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "A table's width" do
  it "should equal sum(column_widths)" do
    pdf = Prawn::Document.new
    table = Prawn::Table.new( [%w[ a b c ], %w[d e f]], pdf,
       :column_widths => { 0 => 50, 1 => 100, 2 => 150 })

    table.width.should == 300
  end
  it "should calculate unspecified column widths even " +
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

  it "should calculate unspecified column widths as "+
     "(max(string_width).ceil + 2*horizontal_padding)" do
    pdf = Prawn::Document.new
    hpad, fs = 3, 12
    columns = 2
    table = Prawn::Table.new( [%w[ foo b ], %w[d foobar]], pdf,
      :horizontal_padding => hpad, :font_size => fs)

    col0_width = pdf.width_of("foo", :size => fs)
    col1_width = pdf.width_of("foobar", :size => fs)

    table.width.should == col0_width.ceil + col1_width.ceil + 2*columns*hpad
  end

  it "should allow mixing autocalculated and preset"+
     "column widths within a single table" do

    pdf = Prawn::Document.new
    hpad, fs = 10, 6
    stretchy_columns = 2
    
    col0_width = 50
    col1_width = pdf.width_of("foo", :size => fs)
    col2_width = pdf.width_of("foobar", :size => fs)
    col3_width = 150

    table = Prawn::Table.new( [%w[snake foo b apple], 
                                         %w[kitten d foobar banana]], pdf,
      :horizontal_padding => hpad, :font_size => fs, 
      :column_widths => { 0 => col0_width, 3 => col3_width } )

        table.width.should == col1_width.ceil + col2_width.ceil + 
                              2*stretchy_columns*hpad + 
                              col0_width.ceil + col3_width.ceil

  end

  it "should not exceed the maximum width of the margin_box" do
      
    pdf = Prawn::Document.new
    expected_width = pdf.margin_box.width

    data = [
      ['This is a column with a lot of text that should comfortably exceed '+
      'the width of a normal document margin_box width', 'Some more text', 
      'and then some more', 'Just a bit more to be extra sure']
    ]

    table = Prawn::Table.new(data, pdf)

    table.width.should == expected_width

  end

  it "should not exceed the maximum width of the margin_box even with manual widths specified" do
      
    pdf = Prawn::Document.new
    expected_width = pdf.margin_box.width

    data = [
      ['This is a column with a lot of text that should comfortably exceed '+
      'the width of a normal document margin_box width', 'Some more text', 
      'and then some more', 'Just a bit more to be extra sure']
    ]


    table = Prawn::Table.new(data, pdf, :column_widths => { 1 => 100 })

    table.width.should == expected_width

  end

  it "should be the width of the :width parameter" do
      
    pdf = Prawn::Document.new
    expected_width = 300

    table = Prawn::Table.new( [%w[snake foo b apple], 
                                         %w[kitten d foobar banana]], pdf,
                                         :width => expected_width
                                         )

    table.width.should == expected_width

  end

  it "should not exceed the :width option" do
      
    pdf = Prawn::Document.new
    expected_width = 400

    data = [
      ['This is a column with a lot of text that should comfortably exceed '+
      'the width of a normal document margin_box width', 'Some more text', 
      'and then some more', 'Just a bit more to be extra sure']
    ]

    table = Prawn::Table.new(data, pdf, :width => expected_width)

    table.width.should == expected_width

  end

  it "should not exceed the :width option even with manual widths specified" do
      
    pdf = Prawn::Document.new
    expected_width = 400

    data = [
      ['This is a column with a lot of text that should comfortably exceed '+
      'the width of a normal document margin_box width', 'Some more text', 
      'and then some more', 'Just a bit more to be extra sure']
    ]

    table = Prawn::Table.new(data, pdf, :column_widths => { 1 => 100 }, :width => expected_width)

    table.width.should == expected_width

  end
      
end   

describe "A table's height" do 
  
  before :each do                                           
    data = [["foo"],["bar"],["baaaz"]]
    pdf = Prawn::Document.new
    @num_rows = data.length
       
    @vpad  = 4
    origin = pdf.y
    pdf.table data, :vertical_padding => @vpad

    @table_height = origin - pdf.y

    @font_height = pdf.font.height
  end   
  
  it "should have a height of n rows" do  
    @table_height.should.be.close(
      @num_rows*@font_height + 2*@vpad*@num_rows, 0.001 )
  end
  
end

describe "A table's content" do

  it "should not cause an error if rendering the very first row causes a page break" do
    Prawn::Document.new( :page_layout => :portrait ) do
      arr = Array(1..5).collect{|i| ["cell #{i}"] }

      move_down( y - (bounds.absolute_bottom + 3) )

      lambda {
        table( arr,
            :font_size          => 9, 
            :horizontal_padding => 3,
            :vertical_padding   => 3,
            :border_width       => 0.05,
            :border_style       => :none,
            :row_colors         => %w{ffffff eeeeee},
            :column_widths      => {0 =>110},
            :position           => :left,
            :headers            => ["exploding header"],
            :align              => :left,
            :align_headers      => :center)
      }.should.not.raise
    end
  end

  it "should output content cell by cell, row by row" do
    data = [["foo","bar"],["baz","bang"]]
    @pdf = Prawn::Document.new
    @pdf.table(data)
    output = PDF::Inspector::Text.analyze(@pdf.render)
    output.strings.should == data.flatten
  end

  it "should add headers to output when specified" do
    data = [["foo","bar"],["baz","bang"]]
    headers = %w[a b]
    @pdf = Prawn::Document.new
    @pdf.table(data, :headers => headers)
    output = PDF::Inspector::Text.analyze(@pdf.render)   
    output.strings.should == headers + data.flatten
  end

  it "should repeat headers across pages" do
    data = [["foo","bar"]]*30
    headers = ["baz","foobar"]
    @pdf = Prawn::Document.new
    @pdf.table(data, :headers => headers)
    output = PDF::Inspector::Text.analyze(@pdf.render)   
    output.strings.should == headers + data.flatten[0..-3] + headers +
      data.flatten[-2..-1]
  end

  it "should allow empty fields" do
    lambda {
      data = [["foo","bar"],["baz",""]]
      @pdf = Prawn::Document.new
      @pdf.table(data)
    }.should.not.raise
  end   
  
  it "should paginate for large tables" do
    # 30 rows fit on the table with default setting, 31 exceed.
    data = [["foo"]] * 31
    pdf = Prawn::Document.new

    pdf.table data
    pdf.page_count.should == 2

    pdf.table data
    pdf.page_count.should == 3
  end
  
  it "should accurately count columns from data" do
    # First data row may contain colspan which would hide true column count
    data = [["Name:",{:text => "Some very long name", :colspan => 5}]]
    pdf = Prawn::Document.new
    table = Prawn::Table.new data, pdf
    table.column_widths.length.should == 6
  end

  it "should allow array syntax for :row_colors" do
    data = [["foo"], ["bar"], ['baz']]
    pdf = Prawn::Document.new
    
    # fill_color() is used to retrieve fill color; ignore it
    pdf.stubs(:fill_color)

    # Verify that fill_color is called in proper sequence for row colors.
    seq = sequence('row_colors')
    %w[cccccc ffffff cccccc].each do |color|
      pdf.expects(:fill_color).with(color).in_sequence(seq)
    end

    pdf.table(data, :row_colors => ['cccccc', 'ffffff'])
  end
    
  it "should allow hash syntax for :row_colors" do
    data = [["foo"], ["bar"], ['baz']]
    pdf = Prawn::Document.new
    
    # fill_color() is used to retrieve fill color; ignore it
    pdf.stubs(:fill_color)

    # Verify that fill_color is called in proper sequence for row colors.
    seq = sequence('row_colors')
    %w[cccccc dddddd eeeeee].each do |color|
      pdf.expects(:fill_color).with(color).in_sequence(seq)
    end

    pdf.table(data, :row_colors => {0 => 'cccccc', 1 => 'dddddd', 
                                    2 => 'eeeeee'})
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

describe "A table, in a column box" do

  it "should flow to the next column rather than always the next page" do
    pdf = Prawn::Document.new do
      column_box [0, cursor], :width => bounds.width, :columns => 2 do
        # 35 rows fit on two columns but not one
        table [["data"]] * 35
      end
    end

    pdf.page_count.should == 1
  end

end

