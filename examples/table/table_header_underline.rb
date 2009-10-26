# encoding: utf-8
#
# Demonstrates the :underline_header border style for Document#table.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "table_header_underline.pdf" do
  table [ ['01/01/2008', 'John Doe', '4.2', '125.00', '525.00'], 
          ['01/12/2008', 'Jane Doe', '3.2', '75.50', '241.60'] ] * 5,
  :position => :center,
  :headers => ['Date', 'Employee', 'Hours', 'Rate', 'Total'],
  :column_widths => { 0 => 75, 1 => 100, 2 => 50, 3 => 50, 4 => 50},
  :border_style => :underline_header
end
