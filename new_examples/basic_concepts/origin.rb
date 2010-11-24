# encoding: utf-8
#
# This is the most important concept you need to learn about Prawn:
#
# Pdf documents have the origin [0,0] on the bottom left corner of the page.
#
# A Bounding Box is a structure that provides boundaries for inserting content
# and it also has the property of relocating the origin to its relative bottom
# left corner.
#
# Even if you never create a Bounding Box explictly, each document already comes
# with one called the margin box. This initial bounding box is the one
# responsible for the document margins.
#
# So practically speaking the origin of a page on a default generated document
# isn't the absolute bottom left corner but the bottom left corner of the margin
# box.
#
# The following snippet strokes a circle on the margin box origin. Then strokes
# the boundaries of a bounding box and a circle on its origin.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
  
  stroke_circle_at [0, 0], :radius => 10
  
  bounding_box [100, 300], :width => 300, :height => 200 do
    stroke_bounds
    stroke_circle_at [0, 0], :radius => 10
  end
end
