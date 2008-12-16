# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
   
Prawn::Document.generate("image-flow.pdf", :page_layout => :landscape) do  
  font.size = 8                           
  stef = "#{Prawn::BASEDIR}/data/images/stef.jpg"  
  
  text "Image at default position with no arguments"
  
  move_down 10
  
  image stef 
  
  text "Centered image flowing" 
  
  image stef, :position => :center   
  
  text "Right aligned image flowing"
                 
  image stef, :position => :right  
  
  text "Explicitly left aligned image flowing"
                 
  move_down 10                 
                 
  image stef, :position => :left     
  
  text "Flowing image at x=50"     
  
  image stef, :position => 50
  
end
