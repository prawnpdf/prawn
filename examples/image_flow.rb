# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
   
Prawn::Document.generate("image-flow.pdf", :page_layout => :landscape) do                             
  stef = "#{Prawn::BASEDIR}/data/images/stef.jpg"  
  
  text "o hai"
  
  image stef 
  
  text "flowing text" 
  
  image stef, :position => :center   
  
  text "beneath images"
                 
  image stef, :position => :right  
  
  text "again"
                 
  image stef, :position => :left     
  
  text "and again"     
  
  image stef, :position => 50
  
end
