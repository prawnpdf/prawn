$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("table.pdf") do 
  table [["foo",    "baaar",             "1" ],
         ["This is","a sample",          "2" ],
         ["Table",  "dont\ncha\nknow?",  "3" ],
         [ "It",    "Rules",             "4" ]],     
    :horizontal_spacing => 0,
    :vertical_spacing   => 0,
    :font_size          => 16 

  text "This should appear just below the table at the original font size"
end
