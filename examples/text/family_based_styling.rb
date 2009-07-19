# encoding: utf-8
#
# This example demonstrates using the :style option for Document#text.
# If you are working with TTF fonts, you'll want to check out the 
# documentation for Document#font_families and register your fonts with it.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("family_style.pdf") do
  ["Courier","Helvetica","Times-Roman"].each do |f|
    [:bold,:bold_italic,:italic,:normal].each do |s|
      font f, :style => s
      text "I'm writing in #{f} (#{s})"
    end
  end
  
  font "Helvetica"
  
  text "Normal"
  text "Bold",        :style => :bold
  text "Bold Italic", :style => :bold_italic
  text "Italic",      :style => :italic
  text "Normal"
end