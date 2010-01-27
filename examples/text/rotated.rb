# encoding: utf-8
#
# Demonstrates transformations
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "rotated_text.pdf", :margin => 0 do |pdf|
  pdf.line_width = 1
  width = 150
  height = 200
  half_width = width / 2
  half_height = height / 2
  angle = 30


  # AROUND THE CENTER
  
  x = pdf.bounds.width / 2 - half_width
  y = pdf.bounds.height / 2 + half_height

  # reference rectangle
  pdf.stroke_rectangle([x, y], width, height)

  # rotated rectangle
  pdf.translate(x + half_width, y - half_height) do
    pdf.rotate(angle) do
      pdf.stroke_rectangle([-half_width, half_height], width, height)
    end
  end

  # rotated text
  pdf.text_box("rotated around the center " * 10,
               :at => [x, y],
               :width => width,
               :height => height,
               :rotation => angle,
               :rotate_around => :center)

  
  # AROUND THE UPPER_LEFT_CORNER
  
  x = pdf.bounds.width - width
  y = height

  # reference rectangle
  pdf.stroke_rectangle([x, y], width, height)

  # rotated rectangle
  pdf.translate(x, y) do
    pdf.rotate(angle) do
      pdf.stroke_rectangle([0, 0], width, height)
    end
  end

  # rotated text
  pdf.text_box("rotated around upper left corner " * 10,
               :at => [x, y],
               :width => width,
               :height => height,
               :rotation => angle)

  
  # AROUND THE UPPER_RIGHT_CORNER
  
  x = 0
  y = height

  # reference rectangle
  pdf.stroke_rectangle([x, y], width, height)

  # rotated rectangle
  pdf.translate(x + width, y) do
    pdf.rotate(angle) do
      pdf.stroke_rectangle([-width, 0], width, height)
    end
  end

  # rotated text
  pdf.text_box("rotated around upper right corner " * 10,
               :at => [x, y],
               :width => width,
               :height => height,
               :rotation => angle,
               :rotate_around => :upper_right)

  
  # AROUND THE LOWER_RIGHT_CORNER
  
  x = 0
  y = pdf.bounds.height

  # reference rectangle
  pdf.stroke_rectangle([x, y], width, height)

  # rotated rectangle
  pdf.translate(x + width, y - height) do
    pdf.rotate(angle) do
      pdf.stroke_rectangle([-width, height], width, height)
    end
  end

  # rotated text
  pdf.text_box("rotated around lower right corner " * 10,
               :at => [x, y],
               :width => width,
               :height => height,
               :rotation => angle,
               :rotate_around => :lower_right)

  
  # AROUND THE LOWER_LEFT_CORNER
  
  x = pdf.bounds.width - width
  y = pdf.bounds.height

  # reference rectangle
  pdf.stroke_rectangle([x, y], width, height)

  # rotated rectangle
  pdf.translate(x, y - height) do
    pdf.rotate(angle) do
      pdf.stroke_rectangle([0, height], width, height)
    end
  end

  # rotated text
  pdf.text_box("rotated around lower left corner " * 10,
               :at => [x, y],
               :width => width,
               :height => height,
               :rotation => angle,
               :rotate_around => :lower_left)
end
