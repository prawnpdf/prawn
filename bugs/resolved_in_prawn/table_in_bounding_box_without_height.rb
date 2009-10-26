# encoding: utf-8 
#
# Issue with tables within stretchy bounding boxes.  Changes to the way
# bounding boxes work caused tables to not properly render within stretchy
# bounding boxes.  
#
# A fix in 200fc36455fa3bee0e1e3bb25d1b5bf73dbf3b52 makes it so the bottom
# of the margin_box will be used as the page boundary in stretchy bounding 
# boxes.  Ideally, this would instead use the nesting bounding box dimensions
# [#80] , but this works for now.
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require "rubygems"
require "prawn"
require "prawn/layout"

Prawn::Document.generate("table_in_bounding_box_without_height.pdf") do 
  bounding_box bounds.top_left, :width => 200 do
    table [%w(These should all be), %w(on the same page)]
  end
end
