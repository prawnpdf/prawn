# encoding: utf-8
#
# Demonstrates automated flowing and positioning of images, as well as
# aligining images along the x-axis via the :position argument.  This is
# useful when used in combination with flowing text, where the exact final
# position of the image is not known ahead of time.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
   
Prawn::Document.generate("image-flow.pdf", :page_layout => :landscape) do  
  self.font_size = 8                           
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
