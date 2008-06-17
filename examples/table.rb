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

    :font_size  => 24, 
    :padding    => 10,
    :border     => 2

  text "This should appear just below the table at the original font size"
end
