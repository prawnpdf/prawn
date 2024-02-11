# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Common Lines'

  text do
    prose <<~TEXT
      Prawn provides helpers for drawing some commonly used lines:

      <code>vertical_line</code> and <code>horizontal_line</code> do just what
      their names imply. Specify the start and end point at a fixed coordinate
      to define the line.

      <code>horizontal_rule</code> draws a horizontal line on the current
      bounding box from border to border, using the current y position.
    TEXT
  end

  example axes: true do
    stroke_color 'ff0000'

    stroke do
      # just lower the current y position
      move_down 50
      horizontal_rule

      vertical_line 100, 300, at: 50

      horizontal_line 200, 500, at: 150
    end
  end
end
