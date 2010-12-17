# encoding: utf-8
#
# Another common styling target are the cell borders.
#
# The <code>borders</code> option accepts an array with the border sides that
# will be drawn. The default is <code>[:top, :bottom, :left, :right]</code>.
#
# <code>border_width</code> sets just that given a numeric value.
#
# <code>border_color</code> accepts an HTML RGB like color string ("FF0000")
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  data = [ ["Look at how the borders will look", "", ""],
           ["They probably won't look the same", "", ""]
         ]
  
  { :borders => [:top, :left],
    :border_width => 3,
    :border_color => "FFCCCC"}.each do |property, value|
      
      text "Cell's #{property}: #{value}:"
      table(data, :cell_style => {property => value})
      move_down 20
  end
end
