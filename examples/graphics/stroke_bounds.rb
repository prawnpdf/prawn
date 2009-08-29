# encoding: utf-8
#
# Demonstrates Document#stroke_bounds, which will stroke a rectange outlining
# the boundaries of the current bounding box.  This is useful for debugging
# and can also be used as a light-weight and lower level alternative to
# Cells.  
#
# Feature borrowed from Josh Knowle's pt at:
# http://github.com/joshknowles/pt/tree/master
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("stroke_bounds.pdf") do 
  stroke_bounds
  
  bounding_box [100,500], :width => 200, :height => 300 do
    text "Hey there, here's some text. " * 10
    stroke_bounds
  end
end
