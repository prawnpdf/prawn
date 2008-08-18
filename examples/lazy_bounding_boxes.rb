$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"                                           
                                                    
file = "lazy_bounding_boxes.pdf"
Prawn::Document.generate(file, :skip_page_creation => true) do                    
  point = [bounds.right-50, bounds.bottom + 25]
  page_counter = lazy_bounding_box(point, :width => 50) do   
    text "Page: #{page_count}"
  end 
  
  10.times do         
    start_new_page
    text "Some text"  
    page_counter.draw
  end
end
  
   
    