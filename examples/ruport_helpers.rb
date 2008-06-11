$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

# Demonstrates some features stolen from Ruport::Formatter::PDF
Prawn::Document.generate("ruport.pdf") do
  move_down 50
  # TODO: Figure out where to set the y cursor to.
  stroke_horizontal_rule
  text "Hi there"
  pad(50) { text "I'm Padded" }
  text "I'm far away"
  stroke_horizontal_line 50, 100
  stroke_vertical_line_at 300, 50, 250

end
