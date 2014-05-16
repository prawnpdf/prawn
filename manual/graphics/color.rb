# encoding: utf-8
#
# We can change the stroke and fill colors providing a color name or CSS color
# to the <code>fill_color</code> and <code>stroke_color</code> methods.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis

  # Fill with Yellow using RGB
  fill_color "#FFFFAA"
  fill_polygon [50, 150], [150, 200], [250, 150],
               [250, 50], [150, 0], [50, 50]

  # Stroke with Purple using CMYK
  stroke_color "cmyk(50%, 100%, 0%, 0%)"
  stroke_rectangle [300, 300], 200, 100

  # Both together
  fill_and_stroke_circle [400, 100], 50
end
