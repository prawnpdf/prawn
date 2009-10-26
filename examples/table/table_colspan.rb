# encoding: utf-8
#
# Demonstrates the use of the :col_span option when using Document#table
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "table_colspan.pdf" do
  data = [ ['01/01/2008', 'John Doe', '4.2', '125.00', '525.00'], 
           ['01/12/2008', 'Jane Doe', '3.2', '75.50', '241.60'] ] * 5
  
  data << [{:text => 'Total', :colspan => 2, :align => :center}, '37.0', '1002.5', '3833']
  
  table data,
  :position => :center,
  :headers => ['Date', 'Employee', 'Hours', 'Rate', 'Total'],
  :column_widths => { 0 => 75, 1 => 100, 2 => 50, 3 => 50, 4 => 50},
  :border_style => :grid
end
