# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

describe "A table's width" do
  it "should equal sum(col_widths)" do
    pdf = Prawn::Document.new
    table = Prawn::Document::Table.new( [%w[ a b c ], %w[d e f]], pdf,
       :widths => { 0 => 50, 1 => 100, 2 => 150 })

    table.width.should == 300
  end

  it "should calculate unspecified column widths as "+
     "(max(string_width).ceil + 2*horizontal_padding)" do
    pdf = Prawn::Document.new
    hpad, fs = 3, 12
    columns = 2
    table = Prawn::Document::Table.new( [%w[ foo b ], %w[d foobar]], pdf,
      :horizontal_padding => hpad, :font_size => fs)

    col0_width = pdf.font.metrics.string_width("foo",fs)
    col1_width = pdf.font.metrics.string_width("foobar",fs)

    table.width.should == col0_width.ceil + col1_width.ceil + 2*columns*hpad
  end

  it "should allow mixing autocalculated and preset"+
     "column widths within a single table" do

    pdf = Prawn::Document.new
    hpad, fs = 10, 6
    stretchy_columns = 2
    
    col0_width = 50
    col1_width = pdf.font.metrics.string_width("foo",fs)
    col2_width = pdf.font.metrics.string_width("foobar",fs)
    col3_width = 150

    table = Prawn::Document::Table.new( [%w[snake foo b apple], 
                                         %w[kitten d foobar banana]], pdf,
      :horizontal_padding => hpad, :font_size => fs, 
      :widths => { 0 => col0_width, 3 => col3_width } )

        table.width.should == col1_width.ceil + col2_width.ceil + 
                              2*stretchy_columns*hpad + 
                              col0_width.ceil + col3_width.ceil

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

describe "Table background colors" do
  setup do
    @default_row_count = 6
    @data              = [["foo","bar"]] * @default_row_count
    @headers           = ["baz","foobar"]
  end

  def expect_background_color( color )
    Prawn::Graphics::CellBlock.any_instance.expects(:background_color=).with(color)
  end

  it "should correctly cycle row colors for PDF::Writer rows and an uncolored header" do
    row_colors     = :pdf_writer
    odd_row_color  = "cccccc"   # These colors are copied from table.rb  Perhaps they
    even_row_color = "ffffff"   # should be constants in Prawn::Document or elsewhere?

    (@default_row_count/2).times do
      expect_background_color( odd_row_color )
      expect_background_color( even_row_color )
    end

    Prawn::Document.new.table(@data, :headers => @headers, :row_colors => row_colors )
  end

  it "should correctly cycle row colors for a custom row color set and an uncolored header" do
    odd_row_color  = "CC0000"
    even_row_color = "0000BB"
    row_colors     = [ odd_row_color, even_row_color ]

    (@default_row_count/2).times do
      expect_background_color( odd_row_color )
      expect_background_color( even_row_color )
    end

    Prawn::Document.new.table(@data, :headers => @headers, :row_colors => row_colors )
  end

  it "should correctly cycle row colors and apply a custom header color when specified" do
    header_row_color = "00DD00"
    odd_row_color    = "CC0000"
    even_row_color   = "0000BB"
    row_colors       = [ odd_row_color, even_row_color ]

    expect_background_color( header_row_color )
    (@default_row_count/2).times do
      expect_background_color( odd_row_color )
      expect_background_color( even_row_color )
    end

    Prawn::Document.new.table(@data, :headers => @headers, :header_color => header_row_color, :row_colors => row_colors )
  end

  it "should correctly cycle row colors even if a header color is specified for a headerless table" do
    header_row_color = "00DD00"
    odd_row_color    = "CC0000"
    even_row_color   = "0000BB"
    row_colors       = [ odd_row_color, even_row_color ]

    (@default_row_count/2).times do
      expect_background_color( odd_row_color )
      expect_background_color( even_row_color )
    end

    Prawn::Document.new.table(@data, :header_color => @header_row_color, :row_colors => row_colors )
  end

  it "should correctly cycle row colors even when only one row color is specified" do
    row_color   = "0000BB"
    row_colors  = [ row_color ]

    @default_row_count.times do
      expect_background_color( row_color )
    end

    Prawn::Document.new.table(@data, :row_colors => row_colors )
  end

  it "should correctly cycle row colors even when more than two row colors are specified" do
    row_color_1   = "0000BB"
    row_color_2   = "00CC00"
    row_color_3   = "DD0000"
    row_colors  = [ row_color_1, row_color_2, row_color_3 ]

    (@default_row_count/3).times do
      expect_background_color( row_color_1 )
      expect_background_color( row_color_2 )
      expect_background_color( row_color_3 )
    end

    Prawn::Document.new.table(@data, :row_colors => row_colors )
  end
end

describe "A table's content" do

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
