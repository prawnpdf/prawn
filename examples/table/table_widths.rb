# encoding: utf-8
#
# Generates a couple simple tables, including some UTF-8 text cells.
# Although this does not show all of the options available to table, the most
# common are used here.  See fancy_table.rb for a more comprehensive example.
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

require "rubygems"
require "prawn"
require "prawn/layout"

Prawn::Document.generate("table_widths.pdf") do 

  data = [
    %w(one two three four),
    %w(five six seven eight),
    %w(nine ten eleven twelve),
    %w(thirteen fourteen fifteen sixteen),
    %w(seventeen eighteen nineteen twenty)
  ]
  headers = ["Column A","Column B","Column C", "Column D"]

  text "A table with a specified width of the document width (within margins)"
  move_down 10

  table data,    
    :position   => :center,
    :headers    => headers,
    :width      => margin_box.width


  move_down 20
  text "A table with a specified width of the document width (within margins) and two fixed width columns"
  move_down 10

  table data,    
    :position      => :center,
    :headers       => headers,
    :width         => margin_box.width,
    :column_widths => {0 => 70, 1 => 70}


  move_down 20
  text "A table with a specified width of 300"
  move_down 10

  table data,    
    :position   => :center,
    :headers    => headers,
    :width      => 300


  move_down 20
  text "A table with too much data is automatically limited to the document width"
  move_down 10

  data << ['some text', 'A long piece of text that will make this cell too wide for the page', 'some more text', 'And more text']

  table data,    
    :position   => :center,
    :headers    => headers

end
