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

end
