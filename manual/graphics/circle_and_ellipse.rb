# encoding: utf-8
#
# To define a <code>circle</code> all you need is the center point and the radius
#
# To define an <code>ellipse</code> you provide the center point and two radii (or axes)
# values. If the second radius value is ommitted, both radii will be equal and
# you will end up drawing a circle.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
  
  stroke_circle [100, 300], 100
    
  fill_ellipse [200, 100], 100, 50
    
  fill_ellipse [400, 100], 50
end
