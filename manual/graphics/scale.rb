# frozen_string_literal: true

require 'prawn/manual_builder'

Prawn::ManualBuilder::Chapter.new do
  title 'Scaling'

  text do
    prose <<~TEXT
      This transformation is used to scale the user space. Give it an scale
      factor and an <code>:origin</code> point and everything inside the block
      will be scaled using the origin point as reference.

      If you omit the <code>:origin</code> option the page origin will be used.
    TEXT
  end

  example do
    width = 100
    height = 50
    y = 190

    x = 50
    stroke_rectangle [x, y], width, height
    text_box 'reference rectangle', at: [x + 10, y - 10], width: width - 20

    scale(2, origin: [x, y]) do
      stroke_rectangle [x, y], width, height
      text_box 'rectangle scaled from upper-left corner', at: [x, y - height - 5], width: width
    end

    x = 350
    stroke_rectangle [x, y], width, height
    text_box 'reference rectangle', at: [x + 10, y - 10], width: width - 20

    scale(2, origin: [x + (width / 2), y - (height / 2)]) do
      stroke_rectangle [x, y], width, height
      text_box 'rectangle scaled from center', at: [x, y - height - 5], width: width
    end
  end
end
