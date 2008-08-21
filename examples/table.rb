# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("table.pdf") do 
  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
  table [["ὕαλον ϕαγεῖν",    "baaar",    "1" ],
         ["This is","a sample",          "2" ],
         ["Table",  "dont\ncha\nknow?",  "3" ],
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4" ],     
         [ "It",    "Rules",             "4123231" ],     
         [ "It",    "Rules",             "22.5" ],     
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

    :font_size  => 24, 
    :horizontal_padding => 10,
    :vertical_padding   => 3,
    :border_width       => 2,
    :position           => :center,
    :headers            => ["Column A","Column B","#"],
    :align              => {1 => :center},
    :align_headers      => :center
                            
  text "This should appear in the original font size, just below the table"     
  move_down 10
  
  table [[ "Wide", "columns", "streeetch"], 
         ["are","mighty fine", "streeeeeeeech"]],
    :widths => { 0 => 200, 1 => 250 }, :position => 5

end
