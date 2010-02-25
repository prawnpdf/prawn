require "#{File.dirname(__FILE__)}/../example_helper.rb"

def radian(degree)
  Math::PI/180*degree
end

def point_on_circle(center, radius, degrees)
  [center[0] + radius*(Math.cos(radian(degrees))), center[1] - radius*(Math.sin(radian(degrees)))]
end

pdf = Prawn::Document.new

pentagon_points = (0..4).map{|i| point_on_circle([200, 400], 100, i * 72)}
pentagram_points = [0, 2, 4, 1, 3].map{|i| pentagon_points[i]}
pdf.stroke_rounded_polygon(20, *pentagram_points)
pdf.fill_and_stroke_rounded_polygon(10, [100, 250], [200, 300], [300, 250],
                 [300, 150], [200, 100], [100, 150])

pdf.render_file "rounded_polygon.pdf"
