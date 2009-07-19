# encoding: utf-8
#
# These helpers will be familiar to Ruport users, and now are supported
# directly in Prawn.   Run the example to see how they work.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

# Demonstrates some features stolen from Ruport::Formatter::PDF
Prawn::Document.generate("ruport.pdf") do
  move_down 50
  # TODO: Figure out where to set the y cursor to.
  stroke_horizontal_rule
  text "Hi there"
  pad(50) { text "I'm Padded" }
  text "I'm far away"
  stroke_horizontal_line 50, 100
  stroke_horizontal_line 50, 100, :at => 300
  stroke_vertical_line 300, 50, :at => 250
end