# encoding: utf-8
#
# This example demonstrates the basic functionality of Prawn's bounding boxes.
# Note that top level bounding boxes are positioned relative to the margin_box.
# 
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("bounding_boxes.pdf") do

  # Generates a box with a top-left of [100,600] and a top-right of [300,600]
  # The box automatically expands as the cursor moves down the page.  Notice
  # that the final coordinates are outlined by a top and bottom line drawn
  # relatively using calculations from +bounds+.
  #
  bounding_box [100,600], :width => 200 do
    move_down 10
    text "The rain in spain falls mainly on the plains " * 5
    move_down 20
    stroke do
      line bounds.top_left,    bounds.top_right
      line bounds.bottom_left, bounds.bottom_right
    end
  end

  # Generates a bounding box from [100, cursor], [300, cursor - 200],
  # where cursor is the current y position.
  #
  bounding_box [100,cursor], :width => 200, :height => 200 do
    stroke do
      circle_at [100,100], :radius => 100
      line bounds.top_left, bounds.bottom_right
      line bounds.top_right, bounds.bottom_left
    end
    
    # Generates a nested bonding box and strokes its boundaries.  Note that
    # this box is anchored relative to its parent bounding box, not the
    # margin_box 
    bounding_box [50,150], :width => 100, :height => 100 do
      stroke_bounds
    end
  end

end                 