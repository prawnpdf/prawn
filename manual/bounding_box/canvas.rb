# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Canvas'

  text do
    prose <<~TEXT
      The origin example already mentions that a new document already comes
      with a margin box whose bottom left corner is used as the origin for
      calculating coordinates.

      What has not been told is that there is one helper for "bypassing" the
      margin box: <code>canvas</code>. This method is a shortcut for creating a
      bounding box mapped to the absolute coordinates and evaluating the code
      inside it.

      The following snippet draws a circle on each of the four absolute
      corners.
    TEXT
  end

  example do
    canvas do
      fill_circle [bounds.left, bounds.top], 30
      fill_circle [bounds.right, bounds.top], 30
      fill_circle [bounds.right, bounds.bottom], 30
      fill_circle [0, 0], 30
    end
  end
end
