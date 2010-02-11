# encoding: utf-8
#
# An early example of basic text generation at absolute positions.
# Mostly kept for nostalgia.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "simple_text.pdf" do       
  fill_color "0000ff"
  text_at "Hello World", :at => [200,420], :size => 32, :rotate => 45
  font "Times-Roman"     
  fill_color "ff0000"
  text_at "Using Another Font", :at => [5,5]    
  start_new_page        
  font "Courier"       
  text_at "Goodbye World", :at => [288,50]     
end
