# encoding: utf-8
#
# Demonstrates overall usage for the Graphics package
#
require File.join(File.dirname(__FILE__), '..', 'example_helper.rb')

Prawn::Document.generate("graphics.pdf") do
  snippet do
    def radian(degree)
      Math::PI/180*degree
    end

    def point_on_circle(center, radius, degrees)
      [center[0] + radius*(Math.cos(radian(degrees))), center[1] - radius*(Math.sin(radian(degrees)))]
    end
    
    pentagon_points = (0..4).map{|i| point_on_circle([200, 400], 100, i * 72)}
    pentagram_points = [0, 2, 4, 1, 3].map{|i| pentagon_points[i]}
    stroke_rounded_polygon(20, *pentagram_points)
    fill_and_stroke_rounded_polygon(10, [100, 250], [200, 300], [300, 250],
                     [300, 150], [200, 100], [100, 150])
  end
end
