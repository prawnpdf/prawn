# encoding: utf-8
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
 
Prawn::Document.generate("simple_table.pdf") do 

  table([["foo", "bar " * 15, "baz"], 
         ["baz", "bar", "foo " * 15]], :cell_style => { :padding => 12 }) do
    cells.borders = []

    # Use the row() and style() methods to select and style a row.
    style row(0), :border_width => 2, :borders => [:bottom]

    # The style method can take a block, allowing you to customize properties
    # per-cell.
    style(columns(0..1)) { |cell| cell.borders |= [:right] }
  end

  move_down 12

  table([%w[foo bar bazbaz], %w[baz bar foofoo]], 
        :cell_style => { :padding => 12 }, :width => bounds.width)

end
