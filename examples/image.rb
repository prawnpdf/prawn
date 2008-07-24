# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
   
Prawn::Document.generate("image.pdf") do 
  filename = File.join("#{Prawn::BASEDIR}/data/images/stef.jpg")
  image filename, :at => [200, 400]
end
