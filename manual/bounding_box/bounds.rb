# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Bounding Box Creation'

  text do
    prose <<~TEXT
      The <code>bounds</code> method returns the current bounding box. This is
      useful because the <code>Prawn::BoundingBox</code> exposes some nice
      boundary helpers.

      <code>top</code>, <code>bottom</code>, <code>left</code> and
      <code>right</code> methods return the bounding box boundaries relative to
      its translated origin. <code>top_left</code>, <code>top_right</code>,
      <code>bottom_left</code> and <code>bottom_right</code> return those
      boundaries pairs inside arrays.

      All these methods have an "absolute" version like
      <code>absolute_right</code>. The absolute version returns the same
      boundary relative to the page absolute coordinates.

      The following snippet shows the boundaries for the margin box side by
      side with the boundaries for a custom bounding box.
    TEXT
  end

  example new_page: true do
    def print_coordinates
      text("top: #{bounds.top}")
      text("bottom: #{bounds.bottom}")
      text("left: #{bounds.left}")
      text("right: #{bounds.right}")

      move_down(10)

      text("absolute top: #{Float(bounds.absolute_top).round(2)}")
      text("absolute bottom: #{Float(bounds.absolute_bottom).round(2)}")
      text("absolute left: #{Float(bounds.absolute_left).round(2)}")
      text("absolute right: #{Float(bounds.absolute_right).round(2)}")
    end

    move_down 20

    text 'Margin box bounds:'
    move_down 5
    print_coordinates

    bounding_box([250, cursor + 140], width: 200, height: 150) do
      text 'This bounding box bounds:'
      move_down 5
      print_coordinates
      transparent(0.5) { stroke_bounds }
    end
  end
end
