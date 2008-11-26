# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("background.pdf", :background => "#{Prawn::BASEDIR}/data/images/letterhead.jpg") do
    text_options.update(:size => 18, :align => :right)
    text "My report caption"
    text_options.update(:size => 12, :align => :left, :spacing => 2)
    move_down font.height * 2
    text "Here is my text explaning this report. " * 20
    move_down font.height
    text "I'm using a soft background. " * 40
end