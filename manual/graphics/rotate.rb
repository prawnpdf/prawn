# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Rotation'

  text do
    prose <<~TEXT
      This transformation is used to rotate the user space. Give it an angle
      and an <code>:origin</code> point about which to rotate and a block.
      Everything inside the block will be drawn with the rotated coordinates.

      The angle is in degrees.

      If you omit the <code>:origin</code> option the page origin will be used.
    TEXT
  end

  example do
    fill_circle [270, 180], 2

    12.times do |i|
      rotate(i * 30, origin: [270, 180]) do
        stroke_rectangle [350, 200], 80, 40
        text_box "Rotated #{i * 30}°", size: 10, at: [360, 185]
      end
    end
  end
end
