# encoding: utf-8
#
# This example demonstrates Document#lazy_bounding_box, which is used for
# storing a set of drawing instructions to be executed later.  This is used
# for header and footer support in Prawn, and can be used for repeating page
# elements in general.
#
# Note that once a lazy bounding box is positioned, it calculates its anchor
# relative to its parent bounding box.  It will be positioned at this exact
# location each time it is redrawn, regardless of the bounds 
# LazyBoundingBox#draw is in.
# 
require "#{File.dirname(__FILE__)}/../example_helper.rb"

file = "lazy_bounding_boxes.pdf"
Prawn::Document.generate(file, :skip_page_creation => true) do
  point = [bounds.right-50, bounds.bottom + 25]
  page_counter = lazy_bounding_box(point, :width => 50) do
    text "Page: #{page_count}"
  end 
  
  10.times do
    start_new_page
    text "Some filler text for the page"  
    page_counter.draw
  end
end
