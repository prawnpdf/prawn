# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("baseline.pdf") do
  pos = self.y - margin_box.absolute_bottom
  stroke do
    horizontal_rule
    line [0,pos], [0,pos - font.height*2]
  end
  
  bounding_box(bounds.top_left, :width => 250) do  
    text "blah blah blah"
    text "fasjkafsk asfkjfj saklfs asfklafs"
  end
  
  bounding_box([300,bounds.top], :width => 250) do
    # This is how you can position the text exactly at the baseline
    move_up font.height
    text "blah blah blah"
    text "fasjkafsk asfkjfj saklfs asfklafs"    
  end
  
  stroke_horizontal_rule
end