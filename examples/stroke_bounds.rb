$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'prawn'

Prawn::Document.generate("stroke_bounds.pdf") do 
  stroke_bounds
  
  bounding_box [100,500], :width => 200, :height => 300 do
    text "Hey there, here's some text. " * 10
    stroke_bounds
  end
end

`open stroke_bounds.pdf`