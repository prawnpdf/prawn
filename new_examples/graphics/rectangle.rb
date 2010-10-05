# encoding: utf-8
#
# These are pretty basic.
#
# Just provide to upper-left corner, width and height.
#
# There's also the rounded_rectangle. Just provide an additional radius value
# for the rounded corners.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
  
  stroke do
    rectangle [100, 300], 100, 200
    
    rounded_rectangle [300, 300], 100, 200, 20
  end
end
