# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
   
Prawn::Document.generate("hold-text-position.pdf") do
  text "bar bar " * 12, :hold_position => true   
  font "Helvetica", :style => :bold
  text "baz baz " * 12, :hold_position => true
  font "Helvetica", :style => :normal
  text "bar bar " * 12                             
end