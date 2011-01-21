# encoding: utf-8
#
# For <code>circle_at</code> all you need is the center point and the
# <code>:radius</code> param
#
# For <code>ellipse_at</code> you provide the center point and two radius
# values. If the second radius value is ommitted, both radius will be equal and
# you will end up drawing a circle.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
  
  stroke_circle_at [100, 300], :radius => 100
    
  fill_ellipse_at [200, 100], 100, 50
    
  fill_ellipse_at [400, 100], 50
end
