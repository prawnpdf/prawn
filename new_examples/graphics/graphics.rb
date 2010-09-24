# encoding: utf-8
#
# Generates example document for the Graphics package
#
require File.expand_path(File.join(File.dirname(__FILE__),
    '..', 'example_helper.rb'))

examples = %w[
  origin
  fill_and_stroke
  lines_and_curves
  common_lines
  hexagon
  rounded_polygons
].map {|file| "#{file}.rb"}

Prawn::Example.generate_example_document(__FILE__, examples)
