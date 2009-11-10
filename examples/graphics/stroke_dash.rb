# encoding: utf-8
#
# Stroke dashing can be applied to any line or curve

require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("stroke_dash.pdf") do
  self.line_width = 1
  base_y = bounds.top

  100.times do |i|
    length = i / 4 + 1
    # space between dashes same length as dash
    space = length
    # start with dash
    phase = 0
    case i % 4
    when 0
      base_y -= 10
    when 1
      # start with space between dashes
      phase = length
    when 2
      base_y -= 10
      # space between dashes half as long as dash
      space = length * 0.5
    when 3
      # space between dashes half as long as dash
      space = length * 0.5
      # start with space between dashes
      phase = length
    end
    dash(length, :space => space, :phase => phase)
    points = [bounds.left, base_y - 2 * i, bounds.right, base_y - 2 * i]
    stroke_line(points)
  end
  i = 100
  base_y -= 10
  undash
  points = [bounds.left, base_y - 2 * i, bounds.right, base_y - 2 * i]
  stroke_line(points)
end
