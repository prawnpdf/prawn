$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
require "rubygems"
require "fastercsv"

headers, *body = FasterCSV.read("#{Prawn::BASEDIR}/examples/addressbook.csv")

Prawn::Document.generate("fancy_table.pdf", :page_layout => :landscape) do

  mask(:y) { table body, :headers => headers }

  table [["This is",   "A Test"    ],
         ["Of tables", "Drawn Side"],
         ["By side",   "and stuff" ]], 
    :position         => 550, 
    :headers          => ["Col A", "Col B"],
    :border           => 2,
    :vertical_padding => 2,
    :font_size        => 10

  move_down 200

  table [%w[1 2 3],%w[4 5 6],%w[7 8 9]], 
    :position => :center,
    :border_style => :grid,
    :font_size => 40

  text "This document demonstrates a number of Prawn's table features", 
        :at => [50,50], :size => 24

end
