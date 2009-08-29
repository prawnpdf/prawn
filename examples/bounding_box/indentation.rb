# encoding: utf-8
#
# This example demonstrates the basic functionality of Prawn's bounding boxes.
# Note that top level bounding boxes are positioned relative to the margin_box.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("indentation.pdf") do

  text "No indentation"
  indent(20) do
    text "Some indentation"
    # Generates a box with a top-left of [100,600] and a top-right of [300,600]
    # The box automatically expands as the cursor moves down the page.  Notice
    # that the final coordinates are outlined by a top and bottom line drawn
    # relatively using calculations from +bounds+.
    #
    bounding_box [100,600], :width => 200 do
      text "A little more indentation"
      indent(20) do
        text "And some more indentation"
        indent(20) do
          text "And some deeper indentation"
        end
      end
    end
    text "Some indentation"
  end
  indent(10) do
    text "A bit of indentation"
  end
  
  text "No indentation"
end
