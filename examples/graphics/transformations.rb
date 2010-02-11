# encoding: utf-8
#
# Demonstrates transformations
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "transformations.pdf" do |pdf|
  width = 50
  height = 100

  # ROTATION
  x = 50
  y = pdf.bounds.top - 50

  pdf.stroke_rectangle([x, y], width, height)
  pdf.draw_text("reference rectangle", :at => [x + width, y - height])
  pdf.rotate(30, :origin => [x, y]) do
    pdf.stroke_rectangle([x, y], width, height)
    pdf.draw_text("rectangle rotated around upper-left corner", :at => [x + width, y - height])
  end

  x = 50
  y = pdf.bounds.top - 200

  pdf.stroke_rectangle([x, y], width, height)
  pdf.draw_text("reference rectangle", :at => [x + width, y - height])
  pdf.rotate(30, :origin => [x + width / 2, y - height / 2]) do
    pdf.stroke_rectangle([x, y], width, height)
    pdf.draw_text("rectangle rotated around center", :at => [x + width, y - height])
  end

  # SCALE
  x = 0
  y = pdf.bounds.top - 500

  pdf.stroke_rectangle([x, y], width, height)
  pdf.draw_text("reference rectangle", :at => [x + width, y - height])
  pdf.scale(2, :origin => [x, y]) do
    pdf.stroke_rectangle([x, y], width, height)
    pdf.draw_text("rectangle scaled from upper-left corner", :at => [x + width, y - height])
  end

  x = 150
  y = pdf.bounds.top - 400

  pdf.stroke_rectangle([x, y], width, height)
  pdf.draw_text("reference rectangle", :at => [x + width, y - height])
  pdf.scale(2, :origin => [x + width / 2, y - height / 2]) do
    pdf.stroke_rectangle([x, y], width, height)
    pdf.draw_text("rectangle scaled from center", :at => [x + width, y - height])
  end
end
