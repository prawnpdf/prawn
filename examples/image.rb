# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
   
Prawn::Document.generate("image.pdf") do     
=begin
  pigs = "#{Prawn::BASEDIR}/data/images/pigs.jpg" 
  image pigs, :at => [50,550]                                        
  
  stef = "#{Prawn::BASEDIR}/data/images/stef.jpg"
  image stef, :at => [75, 75]
  
  text "Please enjoy the pigs", :size => 36, :at => [200,15]   
=end
  
#=begin
   ruport = "#{Prawn::BASEDIR}/data/images/ruport.png"  
   canvas { image ruport, :at => [100,605] }
#=end
end
