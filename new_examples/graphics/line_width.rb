# encoding: utf-8
#
# The name says it all. Just provide a width and all lines stroked afterwards
# will have the new width.
#
# The only important thing to notice here is that you need an explicit receiver
# for the call to work. If you are using the block call to
# Prawn::Document.generate without passing params you will need to call
# line_width on self.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  # Prawn::Document.generate() do
  stroke_axis :height => 250
  
  y = 250
  
  3.times do |i|
    case i
    when 0; line_width = 10        # This call will have no effect
    when 1; self.line_width = 10
    when 2; self.line_width = 25
    end
    
    stroke do
      horizontal_line 50, 150, :at => y
      rectangle [275, y + 25], 50, 50
      circle_at [500, y], :radius => 25
    end
    
    y -= 100
  end
  
  # Return line_width back to normal
  self.line_width = 1
end
