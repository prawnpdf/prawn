# encoding: utf-8
#
# Your old fashioned polygons. Provide some points and it will create a drawing # path following the points. Note the path is set in the same order as you
# provide the points. This opens space for some nice shapes like a pentagram.
#
# Just like with rectangle we also have the rounded_polygon. Only difference is
# the radius param comes before the polygon points.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis

  # Triangle
  stroke_polygon [50, 200], [50, 300], [150, 300]
  
  # Hexagon
  fill_polygon [50, 150], [150, 200], [250, 150],
               [250, 50], [150, 0], [50, 50]
  
  # Pentagram
  pentagon_points = [500, 100], [430, 5], [319, 41], [319, 159], [430, 195]
  pentagram_points = [0, 2, 4, 1, 3].map{|i| pentagon_points[i]}
  
  stroke_rounded_polygon(20, *pentagram_points)
end
