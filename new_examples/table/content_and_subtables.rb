# encoding: utf-8
#
# There are four kind of objects that can be put on table cells:
#   1. String: produces a text cell (the most common usage)
#   2. <code>Prawn::Table::Cell</code>
#   3. <code>Prawn::Table</code>
#   4. Array
#
# Both table and array objects provided as cells will create a subtable (a
# table within a cell).
#
# If you want to provide a cell or a table it is better to
# use the <code>make_cell</code> and <code>make_table</code> methods as they
# don't immediatelly draw the cell or table.
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
