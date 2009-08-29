# encoding: utf-8
#
# Demonstrates fitting an image within a rectangular width and height.
# The image will be scaled down to fit within the box, while preserving
# the aspect ratio.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
   
Prawn::Document.generate("image_fit.pdf", :page_layout => :landscape) do

  pigs = "#{Prawn::BASEDIR}/data/images/pigs.jpg" 
  stroke_rectangle [50,450], 200, 200
  image pigs, :at => [50,450], :fit => [200,200]

end