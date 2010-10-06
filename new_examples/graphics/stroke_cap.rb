# encoding: utf-8
#
# The cap style defines how the edge of a line or curve will be drawn. There are
# three types: :butt (the default), :round and :projecting_square
#
# The difference is better seen with need thicker lines. With :butt lines
# are drawn starting and ending at the exact points provided. With both :round
# and :projecting_square the line is projected beyond the start and end points.
#
# Just like line_width this method needs an explicit receiver to work.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis :height => 290
  
  self.line_width = 25
  y = 250

  3.times do |i|
    case i
    when 0; self.cap_style = :butt
    when 1; self.cap_style = :round
    when 2; self.cap_style = :projecting_square
    end
    
    stroke_horizontal_line 100, 300, :at => y
    stroke_circle_at [400, y], :radius => 15
    
    y -= 100
  end
  
  reset_drawing_settings
end
