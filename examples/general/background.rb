# encoding: utf-8
#
# This example demonstrates the use of the new :background option when
# generating a new Document.  Image is assumed to be pre-fit for your page
# size, and will not be rescaled.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

img = "#{Prawn::BASEDIR}/data/images/letterhead.jpg"

Prawn::Document.generate("background.pdf", :background => img, :margin => 100) do
  text "My report caption", :size => 18, :align => :right

  move_down font.height * 2

  text "Here is my text explaning this report. " * 20, 
    :size => 12, :align => :left, :leading => 2

  move_down font.height

  text "I'm using a soft background. " * 40,
    :size => 12, :align => :left, :leading => 2
end
