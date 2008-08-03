$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'prawn'

Prawn::Document.generate("bounding_boxes.pdf") do   
      
  bounding_box [100,600], :width => 200 do
    text "The rain in spain falls mainly on the plains " * 5
    stroke do
      line bounds.top_left,    bounds.top_right
      line bounds.bottom_left, bounds.bottom_right
    end
  end

  bounding_box [100,500], :width => 200, :height => 200 do
    stroke do
      circle_at [100,100], :radius => 100
      line bounds.top_left, bounds.bottom_right
      line bounds.top_right, bounds.bottom_left
    end   
  
    bounding_box [50,150], :width => 100, :height => 100 do
      stroke_rectangle bounds.top_left, bounds.width, bounds.height
    end   
  end
      
end        
     
                 
                 
                          