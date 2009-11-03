# encoding: utf-8
#
# This demonstrates the Prawn options for document and page margin, similar to CSS shorthand.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

LOREM = ("Lorem ipsum dolor sit amet, consectetur adipisicing elit, "+
"sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "+
"Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris "+
"nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in "+
"reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla "+
"pariatur. Excepteur sint occaecat cupidatat non proident, sunt in " +
"culpa qui officia deserunt mollit anim id est laborum. ") * 20

Prawn::Document.generate("margin.pdf", :margin => 100) do |pdf|

  pdf.text "100 on all sides", :style => :bold
  pdf.text LOREM
  
  pdf.start_new_page(:margin => 100, :left_margin => 0)
  pdf.text "100 on all sides but 0 on the left", :style => :bold
  pdf.text LOREM

  pdf.start_new_page(:margin => [100, 0])
  pdf.text "100 top and bottom, 0 left and right.", :style => :bold
  pdf.text LOREM
  
  pdf.start_new_page(:margin => [100, 0, 50])
  pdf.text "100 top, 0 left and right, 50 bottom.", :style => :bold
  pdf.text LOREM
  
  pdf.start_new_page(:margin => [0, 50, 100, 150])
  pdf.text "0 top, 50 right, 100 bottom, 150 left.", :style => :bold
  pdf.text LOREM

end
