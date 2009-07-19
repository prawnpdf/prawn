# encoding: utf-8
#
# This example demonstrates usage of Document#text with the :align option.
# Available options are :left, :right, and :center, with :left as default.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("alignment.pdf") do
  text "This text should be left aligned"
  text "This text should be centered", :align => :center    
  text "This text should be right aligned", :align => :right
  
  pad(20) { text "This is Flowing from the left. " * 20 }
  
  pad(20) { text "This is Flowing from the center. " * 20, :align => :center }
  
  pad(20) { text "This is Flowing from the right. " * 20, :align => :right }
end
