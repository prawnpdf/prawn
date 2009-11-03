# encoding: utf-8
#
# Demonstrate use of transparency
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("transparency.pdf") do
  fill_color("ff0000")
  fill_circle_at([200, 200], :radius => 200)
  transparent(0.5, 1) do
    fill_color("000000")
    stroke_color("ffffff")
    fill_and_stroke_circle_at([300, 300], :radius => 200)
    fill_color("ffffff")
    text "transparency " * 150, :size => 18
  end
  
  start_new_page

  fill_color("000000")
  fill_rectangle([0, bounds.top], 200, 100)
  transparent(0.5) do
    fill_color("ff0000")
    fill_rectangle([100, bounds.top - 50], 200, 100)
  end
end
