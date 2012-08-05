# encoding: utf-8
#
# We can change the stroke and fill colors providing an HTML rgb 6 digit color
# code string ("AB1234") or 4 values for CMYK.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
  
  # Fill with Yellow
  fill_color "FFFFCC" # RGB
  fill_polygon [50, 150], [150, 200], [250, 150],
               [250, 50], [150, 0], [50, 50]
  
  # Stroke with Purple
  stroke_color 50, 100, 0, 0 # CMYK
  stroke_rectangle [300, 300], 200, 100
  
  # Both together
  fill_and_stroke_circle [400, 100], 50

  # Gradient:
  fill_gradient [10, 330], 400, 50, 'F0FF00', '0000FF'
  bounding_box [10, 300], :width => 450, :height => 150 do
    text "Gradient!", :size => 60
  end
end
