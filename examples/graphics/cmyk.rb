# encoding: utf-8
#
# Demonstrates Prawn's support for CMYK images and colors.
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "prawn"

Prawn::Document.generate("cmyk.pdf", :page_layout => :landscape) do
  fill_color 50, 100, 0, 0
  text "Prawn is CYMK Friendly"
  fractal = "#{Prawn::BASEDIR}/data/images/fractal.jpg"
  image fractal, :at => [50,450]
end
