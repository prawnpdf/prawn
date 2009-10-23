# encoding: utf-8
#
# Stroke dashing can be applied to any line or curve

require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("stroke_dash.pdf") do
  line_width = 1
  base_y = bounds.top

  100.times do |i|
    solid = i / 4 + 1
    # space same length as solid
    space = solid
    # start with solid
    phase = 0
    case i % 4
    when 0
      base_y -= 10
    when 1
      # start with space
      phase = solid
    when 2
      base_y -= 10
      # space half as long as solid
      space = solid * 0.5
    when 3
      # space half as long as solid
      space = solid * 0.5
      # start with space
      phase = solid
    end
    set_stroke_dash(solid, space, phase)
    points = [bounds.left, base_y - 2 * i, bounds.right, base_y - 2 * i]
    stroke_line(points)
  end
  i = 100
  base_y -= 10
  clear_stroke_dash
  points = [bounds.left, base_y - 2 * i, bounds.right, base_y - 2 * i]
  stroke_line(points)
end
