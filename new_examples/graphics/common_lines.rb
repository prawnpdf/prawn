# encoding: utf-8
#
# There are some helpers available for common lines we might want to draw:
#
# vertical_line and horizontal_line do just what their names imply. Specify
# the start and end point at a fixed coordinate and there is your line.
#
# horizontal_rule is the helper for the helper as it draws a horizontal line
# on the current bounding box from border to border, using the current y
# position.
#
require File.expand_path(File.join(File.dirname(__FILE__),
    '..', 'example_helper.rb'))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
  
  stroke do
    # just lower the current y position
    move_down 50  
    horizontal_rule
    
    vertical_line 100, 300, :at => 50
  
    horizontal_line 200, 500, :at => 150
  end
end
