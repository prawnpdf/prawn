# encoding: utf-8
#
# Demonstrates how to use open-uri and Document#image to embed remote image
# files.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

require "open-uri"

Prawn::Document.generate("remote_images.pdf") do 
  image open("http://prawn.majesticseacreature.com/images/prawn.png")
end
