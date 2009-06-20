# encoding: utf-8
#
# This example demonstrates the basic functionality of Prawn's bounding boxes.
# Note that top level bounding boxes are positioned relative to the margin_box.
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'prawn/core'

Prawn::Document.generate("left_padding.pdf") do

  text "No Padding"
  pad_left(20) do
    text "Some padding"
    # Generates a box with a top-left of [100,600] and a top-right of [300,600]
    # The box automatically expands as the cursor moves down the page.  Notice
    # that the final coordinates are outlined by a top and bottom line drawn
    # relatively using calculations from +bounds+.
    #
    bounding_box [100,600], :width => 200 do
      text "A little more padding"
      pad_left(20) do
        text "And some more padding"
        pad_left(20) do
          text "And some deeper padding"
        end
      end
    end
    text "Some padding"
  end
  pad_left(10) do
    text "A bit of padding"
  end
  
  text "No padding"
end
