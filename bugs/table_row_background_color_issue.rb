# As of 96f660660345c7c22923ba51d0124022a3a189ab, table is currently not taking
# in account border widths when filling in rows with background coloring.  This
# means the larger the border, the larger the visible gap between rows.

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("table_with_background_color_problems.pdf") do 
  font "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"
  table [["ὕαλον ϕαγεῖν",    "baaar",             "1" ],
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
    :horizontal_padding => 10,
    :vertical_padding => 3,
    :border     => 2,
    :position   => :center,
    :headers    => ["Column A","Column B","#"],
    :row_colors => ["eeeeee"]

  pad(20) do
    text "This should appear in the original font size"
  end

  table [[ "Wide", "columns", "streeetch"], 
         ["are","mighty fine", "streeeeeeeech"]],
    :widths => { 0 => 200, 1 => 250 }, :position => 5

end
