$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"                                           

Prawn::Document.generate("flow_with_headers_and_footers.pdf")  do

  header margin_box.top_left do 
    text "Here's My Fancy Header", :size => 25, :align => :center   
    stroke_horizontal_rule
  end   
                
  footer [margin_box.left, margin_box.bottom + 25] do
    stroke_horizontal_rule
    text "And here's a sexy footer", :size => 16
  end
                                      
  bounding_box([bounds.left, bounds.top - 50], 
      :width  => bounds.width, :height => bounds.height - 100) do                 
   text "this is some flowing text " * 200    
   
   move_down(20)
   
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
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ],  
          [ "It",    "Rules",             "4" ],     
          [ "It",    "Rules",             "4" ]],     

     :font_size          => 24, 
     :horizontal_padding => 10,
     :vertical_padding   => 3,
     :border_width       => 2,
     :position           => :center,
     :headers            => ["Column A","Column B","#"]
          
 end    
 
end       
                
