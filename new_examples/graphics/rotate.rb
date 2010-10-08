# encoding: utf-8
#
# This transformation is used to rotate the user space. Give it an angle
# and an :origin point to rotate and everything inside the block will be
# drawn with the rotated coordinates.
#
# If you ommit the :origin parameter the page origin will be used.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
  
  fill_circle_at [250, 200], :radius => 2
  
  12.times do |i|
    
    rotate(i * 30, :origin => [250, 200]) do
      
      stroke_rectangle [350, 225], 100, 50
      draw_text "Rotated #{i * 30}°", :size => 10, :at => [360, 205]
    end
  end
end
