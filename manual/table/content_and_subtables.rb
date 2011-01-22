# encoding: utf-8
#
# There are four kinds of objects which can be put in table cells:
#   1. String: produces a text cell (the most common usage)
#   2. <code>Prawn::Table::Cell</code>
#   3. <code>Prawn::Table</code>
#   4. Array
#
# Whenever a table or an array is provided as a cell, a subtable will be created
# (a table within a cell).
#
# If you'd like to provide a cell or table directly, the best way is to
# use the <code>make_cell</code> and <code>make_table</code> methods as they
# don't call <code>draw</code> on the created object.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  cell_1 = make_cell(:content => "this row content comes directly ")
  cell_2 = make_cell(:content => "from cell objects")
  
  two_dimensional_array = [ ["..."],
                            ["subtable from an array"],
                            ["..."] ]
  
  inner_table = make_table([ ["..."],
                             ["subtable from another table"],
                             ["..."] ])
  
  table([ ["just a regular row", "", "", "blah blah blah"],
          [cell_1, cell_2, "", ""],
          ["", "", two_dimensional_array, ""],
          ["just another regular row", "", "", ""],
          ["", "", inner_table, ""]])
end
