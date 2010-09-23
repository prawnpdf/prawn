# encoding: utf-8
#
# Generates example document for the Graphics package
#
require File.join(File.dirname(__FILE__), '..', 'example_helper.rb')

examples = %w[
  origin
  fill_and_stroke
  lines_and_curves
  hexagon
  rounded_polygons
].map {|file| "#{file}.rb"}

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate_example_document(filename, examples)
