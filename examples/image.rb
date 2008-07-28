# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
   
Prawn::Document.generate("image.pdf", :page_layout => :landscape) do     
  pigs = "#{Prawn::BASEDIR}/data/images/pigs.jpg" 
  image pigs, :at => [50,450], :width => 302, :height => 227                                       
  
  stef = "#{Prawn::BASEDIR}/data/images/stef.jpg"
  image stef, :at => [75, 75]
  
  text "Please enjoy the pigs", :size => 36, :at => [200,15]   
  
  ruport = "#{Prawn::BASEDIR}/data/images/ruport.png"  
  image ruport, :at => [400,200] 

  fill_color "ffff33"
  fill_rectangle [400,400], 250, 95

  ruport = "#{Prawn::BASEDIR}/data/images/ruport_transparent.png"  
  image ruport, :at => [400,400] 
end
