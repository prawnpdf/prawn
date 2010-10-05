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
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis :height => 420
end
