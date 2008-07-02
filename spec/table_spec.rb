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
     "(max(string_width) + 2*horizontal_padding)" do
    pdf = Prawn::Document.new
    hpad, fs = 3, 12
    columns = 2
    table = Prawn::Document::Table.new( [%w[ foo b ], %w[d foobar]], pdf,
      :horizontal_padding => hpad, :font_size => fs)

    col0_width = pdf.font_metrics.string_width("foo",fs)
    col1_width = pdf.font_metrics.string_width("foobar",fs)

    table.width.should == col0_width + col1_width + 2*columns*hpad
  end

  it "should allow mixing autocalculated and preset"+
     "column widths within a single table" do

    pdf = Prawn::Document.new
    hpad, fs = 10, 6
    stretchy_columns = 2
    
    col0_width = 50
    col1_width = pdf.font_metrics.string_width("foo",fs)
    col2_width = pdf.font_metrics.string_width("foobar",fs)
    col3_width = 150

    table = Prawn::Document::Table.new( [%w[snake foo b apple], 
                                         %w[kitten d foobar banana]], pdf,
      :horizontal_padding => hpad, :font_size => fs, 
      :widths => { 0 => col0_width, 3 => col3_width } )

        table.width.should == col1_width + col2_width + 2*stretchy_columns*hpad +
                              col0_width + col3_width

  end

  it "should paginate large tables" do
    # 30 rows fit on the table with default setting, 31 exceed.
    data = [["foo"]] * 31
    pdf = Prawn::Document.new

    pdf.table data
    pdf.page_count.should == 2

    pdf.table data
    pdf.page_count.should == 3
  end

  it "should have a height of n rows + vertical padding" do
    data = [["foo"],["bar"],["baaaz"]]
    pdf = Prawn::Document.new
    num_rows = data.length
    vpad     = 4
    
    origin = pdf.y
    pdf.table data, :vertical_padding => vpad

    table_height = origin - pdf.y

    font_height = pdf.font_metrics.font_height(12)

    table_height.should be_close(num_rows*font_height + 2*vpad*num_rows + vpad, 0.001)
  end

end

class TableTextObserver
  attr_accessor :font_settings, :size, :strings
            
  def initialize     
    @font_settings = []
    @fonts = {}
    @strings = []
  end
  
  def resource_font(*params)
    @fonts[params[0]] = params[1].basefont
  end

  def set_text_font_and_size(*params)     
    @font_settings << { :name => @fonts[params[0]], :size => params[1] }
  end     
  
  def show_text(*params)
    @strings << params[0]
  end
end


describe "A table's content" do

  it "should output content cell by cell, row by row" do
    data = [["foo","bar"],["baz","bang"]]
    @pdf = Prawn::Document.new
    @pdf.table(data)
    output = observer(TableTextObserver)
    output.strings.should == data.flatten
  end

  it "should add headers to output when specified" do
    data = [["foo","bar"],["baz","bang"]]
    headers = %w[a b]
    @pdf = Prawn::Document.new
    @pdf.table(data, :headers => headers)
    output = observer(TableTextObserver)
    output.strings.should == headers + data.flatten
  end

  it "should repeat headers across pages" do
    data = [["foo","bar"]]*30
    headers = ["baz","foobar"]
    @pdf = Prawn::Document.new
    @pdf.table(data, :headers => headers)
    output = observer(TableTextObserver)
    output.strings.should == headers + data.flatten[0..-3] + headers +
      data.flatten[-2..-1]
  end
    
end
