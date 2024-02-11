# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Rectangles'

  text do
    prose <<~TEXT
      To draw a rectangle, just provide the upper-left corner, width and height
      to the <code>rectangle</code> method.

      There's also <code>rounded_rectangle</code>. Just provide an additional
      radius value for the rounded corners.
    TEXT
  end

  example axes: true do
    stroke do
      rectangle [100, 300], 100, 200

      rounded_rectangle [300, 300], 100, 200, 20
    end
  end
end
