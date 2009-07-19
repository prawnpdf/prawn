# encoding: utf-8
#
# Padded box is a kind of bounding box which places padding on all sides of
# the current bounds.  This is easier to see than explain, so please run the
# example.
#
# Feature borrowed from Josh Knowle's pt at:
# http://github.com/joshknowles/pt/tree/master
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate('padded_box.pdf') do
  stroke_bounds
  text "Margin box"
  padded_box(25) do
    stroke_bounds
    text "Bounding box padded by 25 on all sides from the margins"
    padded_box(50) do
      stroke_bounds
      text "Bounding box padded by 50 on all sides from the parent bounds"
    end
  end
end
