# encoding: utf-8
#
# Demonstrates transformations
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "rotated_text.pdf" do |pdf|
  pdf.line_width = 1
  width = 150
  height = 200
  half_width = width / 2
  half_height = height / 2
  angle = 30


  # AROUND THE CENTER
  
  x = pdf.bounds.width / 2 - half_width
  y = pdf.bounds.height / 2 + half_height

  pdf.stroke_rectangle([x, y], width, height)
  pdf.rotate(angle, :origin => [x + half_width, y - half_height]) do
    pdf.stroke_rectangle([x, y], width, height)
  end
  pdf.text_box("rotated around the center " * 10,
               :at => [x, y],
               :width => width,
               :height => height,
               :rotate => angle,
               :rotate_around => :center)

  
  # AROUND THE UPPER_LEFT_CORNER
  
  x = pdf.bounds.width - width
  y = height

  pdf.stroke_rectangle([x, y], width, height)
  pdf.rotate(angle, :origin => [x, y]) do
    pdf.stroke_rectangle([x, y], width, height)
  end
  pdf.text_box("rotated around upper left corner " * 10,
               :at => [x, y],
               :width => width,
               :height => height,
               :rotate => angle)

  
  # AROUND THE UPPER_RIGHT_CORNER
  
  x = 0
  y = height

  pdf.stroke_rectangle([x, y], width, height)
  pdf.rotate(angle, :origin => [x + width, y]) do
    pdf.stroke_rectangle([x, y], width, height)
  end
  pdf.text_box("rotated around upper right corner " * 10,
               :at => [x, y],
               :width => width,
               :height => height,
               :rotate => angle,
               :rotate_around => :upper_right)

  
  # AROUND THE LOWER_RIGHT_CORNER
  
  x = 0
  y = pdf.bounds.height

  pdf.stroke_rectangle([x, y], width, height)
  pdf.rotate(angle, :origin => [x + width, y - height]) do
    pdf.stroke_rectangle([x, y], width, height)
  end
  pdf.text_box("rotated around lower right corner " * 10,
               :at => [x, y],
               :width => width,
               :height => height,
               :rotate => angle,
               :rotate_around => :lower_right)

  
  # AROUND THE LOWER_LEFT_CORNER
  
  x = pdf.bounds.width - width
  y = pdf.bounds.height

  pdf.stroke_rectangle([x, y], width, height)
  pdf.rotate(angle, :origin => [x, y - height]) do
    pdf.stroke_rectangle([x, y], width, height)
  end
  pdf.text_box("rotated around lower left corner " * 10,
               :at => [x, y],
               :width => width,
               :height => height,
               :rotate => angle,
               :rotate_around => :lower_left)
end
