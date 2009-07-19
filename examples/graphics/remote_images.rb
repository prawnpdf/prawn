# encoding: utf-8
#
# Demonstrates how to use open-uri and Document#image to embed remote image
# files.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

require "open-uri"

Prawn::Document.generate("remote_images.pdf") do 
  image open("http://prawn.majesticseacreature.com/media/prawn_logo.png")
end