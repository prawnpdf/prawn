# encoding: utf-8
#
# To produce this manual we use some helper methods used that are
# not from the Prawn API.
#
# They are defined on the example_helper.rb file
#
# <code>stroke_axis</code> prints the x and y axis for the current bounding box
# with markers in 100 increments
#
# <code>reset_drawing_settings</code> sets all drawing options to the default
# values
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
end
