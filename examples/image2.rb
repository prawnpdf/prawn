# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
           
Prawn::Document.generate("image2.pdf", :page_layout => :landscape) do     
  pigs = "#{Prawn::BASEDIR}/data/images/pigs.jpg" 
  image pigs, :at => [50,450], :width => 450                                      

  dice = "#{Prawn::BASEDIR}/data/images/dice.png"
  image dice, :at => [50, 450], :scale => 0.75 
end
         