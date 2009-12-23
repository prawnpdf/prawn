# encoding: utf-8
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
 
Prawn::Document.generate("simple_table.pdf") do 

  table([["foo", "bar", "baz"], 
         ["baz", "bar", "foo"]]) do |t|
    # Set some properties for all cells
    t.cells.padding = 12
    t.cells.borders = []

    # Use the row() and style() methods to select and style a row.
    t.row(0).style :border_width => 2, :borders => [:bottom]

    # The style method can take a block, allowing you to customize properties
    # per-cell.
    t.columns(0..1).style { |cell| cell.borders |= [:right] }
  end

end
