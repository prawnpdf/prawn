# encoding: utf-8
#
# Generates example document for the Graphics package
#
require File.join(File.dirname(__FILE__), '..', 'example_helper.rb')

examples = %w[
  origin
  drawing_primitives
  hexagon
  rounded_polygons
].map {|file| "#{file}.rb"}

Prawn::Example.generate_example_document('graphics.pdf', examples)
