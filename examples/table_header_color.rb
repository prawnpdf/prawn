# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate "table_header_color.pdf" do
  table [ ['01/01/2008', 'John Doe', '4.2', '125.00', '525.00'], 
          ['01/12/2008', 'Jane Doe', '3.2', '75.50', '241.60'] ] * 20,
  :position => :center,
  :headers => ['Date', 'Employee', 'Hours', 'Rate', 'Total'],
  :widths => { 0 => 75, 1 => 100, 2 => 50, 3 => 50, 4 => 50},
  :border_style => :grid,
  :header_color => 'f07878',
  :header_text_color  => "990000",
  :row_colors => ["FFCCFF","CCFFCC"]
end