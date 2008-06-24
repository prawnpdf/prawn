$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("table.pdf") do 
  font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf"
  table [["foo",    "baaar",             "1" ],
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
         [ "It",    "Rules",             "4" ]],     

    :font_size  => 18, 
    :horizontal_padding => 10,
    :vertical_padding => 3,
    :border     => 2,
    :position   => :center,
    :headers    => ["Column A","Column B","#"]

  pad(20) do
    text "This should appear in the original font size"
  end

  table [[ "Wide", "columns", "streeetch"], 
         ["are","mighty fine", "streeeeeeeech"]],
    :widths => { 0 => 200, 1 => 250 }, :position => 5

end
