# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Stroke Join'

  text do
    prose <<~TEXT
      The join style defines how the intersection between two lines is drawn.
      There are three types: <code>:miter</code> (the default),
      <code>:round</code> and <code>:bevel</code>.

      Just like <code>cap_style</code>, the difference between styles is better
      seen with thicker lines.
    TEXT
  end

  example do
    self.line_width = 25

    %i[miter round bevel].each_with_index do |style, i|
      self.join_style = style

      y = 200 - (i * 100)
      stroke do
        move_to(100, y)
        line_to(200, y + 100)
        line_to(300, y)
      end
      stroke_rectangle [400, y + 75], 50, 50
    end
  end
end
