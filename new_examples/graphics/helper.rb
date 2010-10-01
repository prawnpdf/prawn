# encoding: utf-8
#
# Throughout the graphics reference there are some helper methods used that are
# not from the Prawn API.
#
# They are defined on (TODO: insert path or show the actual code) the
# example_helper.rb file
#
# stroke_axis prints the x and y axis for the current bounding box with markers
# in 100 increments
#
# drawing_box creates a new bounding box with smaller width than the current
# bounding box, executes the provided block and strokes the bounds
#
require File.expand_path(File.join(File.dirname(__FILE__),
    '..', 'example_helper.rb'))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis :height => 420
  
  text "outside"
  drawing_box :height => 200 do
    text "inside"
  end
end
