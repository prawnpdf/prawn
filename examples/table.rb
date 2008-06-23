$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("table.pdf") do 
  font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf"
  data =  [["foo",    "baaar",             "1" ],
         ["This is","a sample",          "2" ],
         ["Table",  "dont\ncha\nknow?",  "3" ],
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules\nwith an iron fist", "x" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ]]

  table data,
    :font_size  => 20, 
    :padding    => 10,
    :border     => 2,
    :position   => :center
 
  pad(20) do
    text "This should appear in the original font size"
  end

  table data,
    :font_size  => 20,
    :padding    => 10,
    :border     => 2,
    :position   => :center,
    :style      => :grid

  pad(20) do
    text "The table above is in grid style"
  end

  table [[ "Wide", "columns", "streeetch"], 
         ["are","mighty fine", "streeeeeeeech"]],
    :widths => { 0 => 200, 1 => 250 }, :position => 5,
    :headers => [ "Col A", "Col B", "Col C" ]

  pad(20) do
    text "A table with headers"
  end

  table [[ "Wide", "columns", "streeetch"], 
         ["are","mighty fine", "streeeeeeeech"]],
    :widths => { 0 => 200, 1 => 250 }, :position => 5,
    :headers => [ "Col A", "Col B", "Col C" ],
    :style => :grid

  pad(20) do
    text "A table with headers in grid style"
  end

end
