# encoding: utf-8
#
# An early example of basic text generation at absolute positions.
# Mostly kept for nostalgia.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "simple_text.pdf" do       
  fill_color "0000ff"
  draw_text "Hello World", :at => [200,420], :size => 32, :rotate => 45
  font "Times-Roman"     
  fill_color "ff0000"
  draw_text "Using Another Font", :at => [5,5]    
  start_new_page        
  font "Courier"       
  draw_text "Goodbye World", :at => [288,50]     
end
