# encoding: utf-8
#
# The cap style defines how the edge of a line or curve will be drawn. There are
# three types: <code>:butt</code> (the default), <code>:round</code> and
# <code>:projecting_square</code>
#
# The difference is better seen with thicker lines. With <code>:butt</code> lines
# are drawn starting and ending at the exact points provided. With both
# <code>:round</code> and <code>:projecting_square</code> the line is projected
# beyond the start and end points.
#
# Just like <code>line_width=</code> the <code>cap_style=</code> method needs an explicit receiver to
# work.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
  
  self.line_width = 25
  y = 250

  3.times do |i|
    case i
    when 0; self.cap_style = :butt
    when 1; self.cap_style = :round
    when 2; self.cap_style = :projecting_square
    end
    
    stroke_horizontal_line 100, 300, :at => y
    stroke_circle [400, y], 15
    
    y -= 100
  end
  
  reset_drawing_settings
end
