# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Color'

  text do
    prose <<~TEXT
      We can change the stroke and fill colors providing an HTML rgb 6 digit
      color code string ("AB1234") or 4 values for CMYK.
    TEXT
  end

  example do
    # Fill with Orange using RGB (Unlike css, there is no leading #)
    fill_color 'FF8844'
    fill_polygon [50, 150], [150, 200], [250, 150], [250, 50], [150, 0], [50, 50]

    # Stroke with Purple using CMYK
    stroke_color 50, 100, 0, 0
    stroke_rectangle [300, 300], 200, 100

    # Both together
    fill_and_stroke_circle [400, 100], 50
  end
end
