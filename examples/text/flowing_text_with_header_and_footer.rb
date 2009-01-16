# encoding: utf-8       
# 
# Multi-faceted example that demonstrates a document flowing between header
# and footer regions.  At the moment, headers and footers in Prawn are run
# using the current font settings (among other things), for each page.  This
# means that it is important to non-destructively set your desired styling 
# within your headers and footers, as shown below.  
#
# Future versions of Prawn may make this more convenient somehow.
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "prawn"                                           

Prawn::Document.generate("flow_with_headers_and_footers.pdf")  do

  header margin_box.top_left do 
    font "Helvetica" do
      text "Here's My Fancy Header", :size => 25, :align => :center   
      stroke_horizontal_rule
    end
  end   
                
  footer [margin_box.left, margin_box.bottom + 25] do
    font "Helvetica" do
      stroke_horizontal_rule
      text "And here's a sexy footer", :size => 16
    end
  end
                                      
  bounding_box([bounds.left, bounds.top - 50], 
      :width  => bounds.width, :height => bounds.height - 100) do                 
   text "this is some flowing text " * 200    
   
   
 end    
 
end
