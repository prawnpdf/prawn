# As of 96f660660345c7c22923ba51d0124022a3a189ab, table is currently not taking
# in account border widths when filling in rows with background coloring.  This
# means the larger the border, the larger the visible gap between rows.    
#
# This problem was fixed in 97d9bf083fd9423d17fd1efca36ea675ff34a6d7, but
# there remains a very minor issue when the border size is 1 for the headers.
# Because this almost appears to be a feature display-wise, we will leave it 
# alone for now.
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require "rubygems"
require "prawn"
require "prawn/layout"

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

    :font_size  => 10, 
    :horizontal_padding => 10,
    :vertical_padding => 3,
    :border     => 1,
    :position   => :center,
    :headers    => ["Column A","Column B","#"],
    :row_colors => ["cccccc"]

  pad(20) do
    text "This should appear in the original font size"
  end

  table [[ "Wide", "columns", "streeetch"], 
         ["are","mighty fine", "streeeeeeeech"]],
    :column_widths => { 0 => 200, 1 => 250 }, :position => 5

end
