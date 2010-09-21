# encoding: utf-8
#
# Now your polygons have rounded borders!
#
require File.join(File.dirname(__FILE__), '..', 'example_helper.rb')

Prawn::Example.generate('rounded_polygons.pdf') do
  def radian(degree)
    Math::PI/180*degree
  end

  def point_on_circle(center, radius, degrees)
    [center[0] + radius*(Math.cos(radian(degrees))),
        center[1] - radius*(Math.sin(radian(degrees)))]
  end

  drawing_box(:height => 300) do
    pentagon_points = (0..4).map{|i| point_on_circle([400, 150], 100, i * 72)}
    pentagram_points = [0, 2, 4, 1, 3].map{|i| pentagon_points[i]}
    stroke_rounded_polygon(20, *pentagram_points)
    fill_and_stroke_rounded_polygon(10, [50, 200], [150, 250], [250, 200],
                                        [250, 100], [150, 50], [50, 100])
  end
end
