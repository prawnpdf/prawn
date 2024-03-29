# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Stroke Cap'

  text do
    prose <<~TEXT
      The cap style defines how the edge of a line or curve will be drawn.
      There are three types: <code>:butt</code> (the default),
      <code>:round</code> and <code>:projecting_square</code>.

      The difference is better seen with thicker lines. With <code>:butt</code>
      lines are drawn starting and ending at the exact points provided. With
      both <code>:round</code> and <code>:projecting_square</code> the line is
      projected beyond the start and end points.

      Just like <code>line_width=</code> the <code>cap_style=</code> method
      needs an explicit receiver to work.
    TEXT
  end

  example axes: true do
    self.line_width = 25

    %i[butt round projecting_square].each_with_index do |cap, i|
      self.cap_style = cap

      y = 250 - (i * 100)
      stroke_horizontal_line 100, 300, at: y
      stroke_circle [400, y], 15
    end
  end
end
