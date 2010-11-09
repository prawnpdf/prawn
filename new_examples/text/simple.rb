# encoding: utf-8
#
# Text rendering can be as simple or as complex as you want.
#
# This example cover the most basic method: <code>text</code>. It is meant for
# free flowing text. The provided text will flow according to the current
# bounding box width and height. It will also flow onto the next page if the
# bottom of the bounding box is reached.
#
# The text will start being rendered on the current cursor position. When it
# finishes rendering, the cursor is left directly below the text.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "This text will flow along the margin box width. " * 5
  text "This line will be close to the previous text."
  
  move_down 50
  text "This line will go just after we moved the cursor down."
  
  bounding_box [100, 250], :width => 200, :height => 200 do
    text "This text will flow along this bounding box we created for it. " * 5
  end
  
  text "And this line will go below the bounding box."
end
