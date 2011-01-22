# encoding: utf-8
#
# To define a <code>circle_at</code> all you need is the center point and the
# <code>:radius</code> param
#
# To define an <code>ellipse_at</code> you provide the center point and two radii (or axes)
# values. If the second radius value is ommitted, both radii will be equal and
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
