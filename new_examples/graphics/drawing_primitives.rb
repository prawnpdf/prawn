# encoding: utf-8
#
# There are two drawing primitives on Prawn: line_to and curve_to
# 
# curve_to draws a Bezier curve according to the :bounds param
# 
# Both of them require require a drawing position to be initially set with
# move_to
# 
# The following code sets the initial drawing position, defines some lines
# and curves and them strokes the path
# 
require File.join(File.dirname(__FILE__), '..', 'example_helper.rb')

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  move_to 100, 100
  
  line_to 150, 200
  line_to 0, 300
  
  curve_to [500, 400], :bounds => [[100, 350], [350, 100]]
  curve_to [300, 0], :bounds => [[50, 200], [450, 10]]
  
  stroke
end
