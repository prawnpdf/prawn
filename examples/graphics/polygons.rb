# encoding: utf-8
# 
# Basic polygon drawing example.  See also: hexagon.rb
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

pdf = Prawn::Document.new

10.times do |i|
  pdf.stroke_polygon [ 50 + i*25,   50 + i*25], 
                     [100 + i*25,   50 + i*25],
                     [100 + i*25,  100 + i*25] 
  pdf.stroke_rectangle [0,600], 5*i, 10*i  
end

pdf.render_file "pretty_polygons.pdf"