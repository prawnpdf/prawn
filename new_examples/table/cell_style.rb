# encoding: utf-8
#
# To style all the table cells you can use the <code>:cell_style</code> option
# from the table methods. It accepts a hash with the cell style options.
#
# Some straightforward options are <code>width</code>, <code>height</code>,
# and <code>padding</code>. All three accept numeric values to set the property.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  data = [ ["Look at how this text will look when we style the cells", "", ""],
           ["It probably won't look the same", "", ""]
         ]
  
  {:width => 160, :height => 50, :padding => 12}.each do |property, value|
    text "Cell's #{property}: #{value}:"
    table(data, :cell_style => {property => value})
    move_down 20
  end
end
