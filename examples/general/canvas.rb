# encoding: utf-8
#
# Demonstrates how to enable absolute positioning in Prawn by temporarily
# removing the margin_box via Document#canvas()
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("canvas.pdf") do
  canvas do
    text "This text should appear at the absolute top left"

    # stroke a line to show that the relative coordinates are the same as absolute
    stroke_line [bounds.left,bounds.bottom], [bounds.right,bounds.top]
  end
end
