# encoding: utf-8
#
# Text rendering can be as simple or as complex as you want.
#
# This example cover the most basic method: <code>text</code>. It is meant for
# free flowing text. The provided string will flow according to the current
# bounding box width and height. It will also flow onto the next page if the
# bottom of the bounding box is reached.
#
# The text will start being rendered on the current cursor position. When it
# finishes rendering, the cursor is left directly below the text.
#
# This example also show text flowing accross pages folowing the margin box and
# other bounding boxes.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "This text will flow along the margin box width. " * 5
  text "This line will be close to the previous text."
  
  move_down 50
  text "This line will go just after we moved the cursor down."
  
  move_cursor_to 50
  text "This text will flow to the next page. " * 20
  
  y_position = cursor - 50
  bounding_box [0, y_position], :width => 200, :height => 150 do
    transparent(0.5) { stroke_bounds }
    text "This text will flow along this bounding box we created for it. " * 5
  end
  
  bounding_box [300, y_position], :width => 200, :height => 150 do
    transparent(0.5) { stroke_bounds }
    text "Now look what happens when the free flowing text reaches the end " +
         "of a bounding box that is narrower than the margin box." +
         " . " * 200 +
         "It continues on the next page as if the previous bounding box " +
         "was cloned. If we want it to have the same border as the one on " +
         "the previous page we will need to stroke the rectangle again."
    transparent(0.5) { stroke_bounds }
  end
end
