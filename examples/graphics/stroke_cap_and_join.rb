# encoding: utf-8
#
# Stroke dashing can be applied to any line or curve

require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("stroke_cap_and_join.pdf") do
  self.line_width = 25
  x0 = bounds.left + 100
  x1 = bounds.left + 200
  x2 = bounds.left + 300

  y = bounds.top - 125

  3.times do |i|
    case i
    when 0
      self.join_style = :miter
    when 1
      self.join_style = :round
    when 2
      self.join_style = :bevel
    end
    stroke do
      move_to(x0, y)
      line_to(x1, y + 100)
      line_to(x2, y)
    end
    y -= 100
  end
  

  3.times do |i|
    case i
    when 0
      self.cap_style = :butt
    when 1
      self.cap_style = :round
    when 2
      self.cap_style = :projecting_square
    end
    stroke_line([x0, y, x2, y])
    y -= 30
  end
end
