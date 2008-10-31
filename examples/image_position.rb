# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
   
Prawn::Document.generate("image_position.pdf", :page_layout => :landscape) do

  dice = "#{Prawn::BASEDIR}/data/images/dice.png"

  image dice, :scale => 0.2, :position => :left
  image dice, :scale => 0.2, :position => :right
  image dice, :scale => 0.2, :position => :center
  image dice, :scale => 0.2, :position => :center, :vposition => :center
  image dice, :scale => 0.2, :position => :center, :vposition => :bottom
  
end
