# encoding: utf-8
#
# To produce this manual we use the <code>stroke_axis</code> helper method
# within examples but it is not from the Prawn API. It is defined on this file:
#
# https://github.com/prawnpdf/prawn/blob/master/manual/example_helper.rb
#
# <code>stroke_axis</code> prints the x and y axis for the current bounding box
# with markers in 100 increments
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
end
