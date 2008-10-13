$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
require "open-uri"

Prawn::Document.generate("remote_images.pdf") do 
  image open("http://prawn.majesticseacreature.com/media/prawn_logo.png")
end