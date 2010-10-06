# encoding: utf-8
#
# Generates example document for the Graphics package
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

examples = [
  "helper",
  "origin",
  "fill_and_stroke",
  "lines_and_curves",
  "common_lines",
  "rectangle",
  "polygon",
  "circle_and_ellipse",
  "line_width",
  "stroke_cap",
  "stroke_join"
].map {|file| "#{file}.rb"}

Prawn::Example.generate_example_document(__FILE__, examples)
