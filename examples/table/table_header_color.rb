# encoding: utf-8
#
# Demonstrates explicitly setting the :header_color rather than inferring
# it from :row_colors in Document#table
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "table_header_color.pdf" do
  table [ ['01/01/2008', 'John Doe', '4.2', '125.00', '525.00'], 
          ['01/12/2008', 'Jane Doe', '3.2', '75.50', '241.60'] ] * 20,
  :position => :center,
  :headers => ['Date', 'Employee', 'Hours', 'Rate', 'Total'],
  :column_widths => { 0 => 75, 1 => 100, 2 => 50, 3 => 50, 4 => 50},
  :border_style => :grid,
  :header_color => 'f07878',
  :header_text_color  => "990000",
  :row_colors => ["FFCCFF","CCFFCC"]
end
