# encoding: utf-8
#
# Prawn supports two different methods for drawing both lines and curves.
#
# line_to and curve_to set the drawing path from the current drawing position
# to the specified point. The initial drawing position can be set with move_to.
# They are useful when you want to chain successive calls because the drawing
# position is set to the specified point afterwards.
#
# line and curve set the drawing path between the two specified points.
#
# Both curve methods define a Bezier curve bounded by two aditional points
# provided as the :bounds param
#
require File.expand_path(File.join(File.dirname(__FILE__),
    '..', 'example_helper.rb'))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  # line_to and curve_to
  stroke do
    move_to 0, 0
  
    line_to 100, 100
    line_to 0, 100
  
    curve_to [150, 250], :bounds => [[20, 200], [120, 200]]
    curve_to [200, 0], :bounds => [[150, 200], [450, 10]]
  end
  
  # line and curve
  stroke do
    line [300,200], [400,50]
    curve [500, 0], [400, 200], :bounds => [[600, 300], [300, 450]]
  end
end
