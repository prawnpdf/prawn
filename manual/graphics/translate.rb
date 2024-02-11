# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Translation'

  text do
    prose <<~TEXT
      This transformation is used to translate the user space. Just provide the
      x and y coordinates for the new origin.
    TEXT
  end

  example axes: true do
    1.upto(3) do |i|
      x = i * 50
      y = i * 100
      translate(x, y) do
        # Draw a point on the new origin
        fill_circle [0, 0], 2
        draw_text "New origin after translation to [#{x}, #{y}]", at: [5, -3]

        stroke_rectangle [100, 50], 200, 30
        text_box 'Top left corner at [100, 50]', at: [110, 40], width: 180
      end
    end
  end
end
