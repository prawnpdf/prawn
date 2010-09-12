# encoding: utf-8
#
# Demonstrates overall usage for the Graphics package
#
require File.join(File.dirname(__FILE__), '..', 'example_helper.rb')

Prawn::Document.generate("graphics.pdf") do
  
  load_example('rounded_polygons.rb')
  
end
