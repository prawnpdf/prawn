# encoding: utf-8
#
# Demonstrates the many controls over alignment and positioning in Prawn
# tables.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "table_header_align.pdf" do
  table [ ['01/01/2008', 'John Doe', '4.2', '125.00', '525.00'],
	  ['01/12/2008', 'Jane Doe', '3.2', { :text => '75.5', :align => :center }, '241.60'] ] * 20,
  :position => :center,
  :headers => ['Date', 'Employee', 'Hours', 'Rate', 'Total'],
  :column_widths => { 0 => 75, 1 => 100, 2 => 50, 3 => 50, 4 => 50},
  :border_style => :grid,
  :align => { 0 => :right, 1 => :left, 2 => :right, 3 => :right, 4 => :right },
  :align_headers => { 0 => :center, 2 => :left, 3 => :left, 4 => :right }
end
