# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Circles and Ellipses'

  text do
    prose <<~TEXT
      To define a <code>circle</code> all you need is the center point and the
      radius.

      To define an <code>ellipse</code> you provide the center point and two
      radii (or axes) values. If the second radius value is omitted, both radii
      will be equal and you will end up drawing a circle.
    TEXT
  end

  example axes: true do
    stroke_circle [100, 300], 100

    fill_ellipse [200, 100], 100, 50

    fill_ellipse [400, 100], 50
  end
end
