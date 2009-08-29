# encoding: utf-8
#
# Demonstrates vertical and horizontal positioning of images.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
   
Prawn::Document.generate("image_position.pdf", :page_layout => :landscape) do

  dice = "#{Prawn::BASEDIR}/data/images/dice.png"

  image dice, :scale => 0.2, :position => :left,   :vposition => :top
  image dice, :scale => 0.2, :position => :right,  :vposition => :top
  image dice, :scale => 0.2, :position => :center, :vposition => :top
  image dice, :scale => 0.2, :position => :center, :vposition => :center
  image dice, :scale => 0.2, :position => :center, :vposition => :bottom
  
end
