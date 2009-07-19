# encoding: utf-8
#
# Demonstrates various table and cell features.  
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
   
headers, body = nil, nil  

dir = File.expand_path(File.dirname(__FILE__))
     
ruby_18 do        
  require "fastercsv" 
  headers, *body = FasterCSV.read("#{dir}/addressbook.csv")   
end

ruby_19 do            
  require "csv"
  headers, *body = CSV.read("#{dir}/addressbook.csv", 
                      :encoding => "utf-8")
end
                                                                                  
Prawn::Document.generate("fancy_table.pdf", :page_layout => :landscape) do
  
  #font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

  mask(:y) { table body, :headers      => headers, 
                         :align        => :center,
                         :border_style => :grid     }

  table [["This is",   "A Test"    ],
         [  Prawn::Table::Cell.new( :text => "Of tables",
                                       :background_color => "ffccff" ),
          "Drawn Side"], ["By side",   "and stuff" ]], 
    :position         => 600, 
    :headers          => ["Col A", "Col B"],
    :border_width     => 1,
    :vertical_padding => 5,
    :horizontal_padding => 3,
    :font_size        => 10,
    :row_colors       => :pdf_writer,
    :column_widths => { 1 => 50 }

  move_down 150

  table [%w[1 2 3],%w[4 5 6],%w[7 8 9]], 
    :position => :center,
    :border_width   => 0,
    :font_size => 40

  cell [500,300],
    :text => "This free flowing textbox shows how you can use Prawn's "+
      "cells outside of a table with ease.  Think of a 'cell' as " +
      "simply a limited purpose bounding box that is meant for laying " +
      "out blocks of text and optionally placing a border around it",
    :width => 225, :padding => 10, :border_width => 2

  font_size 24

  cell [50,75], 
    :text => "This document demonstrates a number of Prawn's table features",
    :border_style => :no_top, # :all, :no_bottom, :sides
    :horizontal_padding => 5
end
