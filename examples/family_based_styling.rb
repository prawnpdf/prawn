# coding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("family_style.pdf") do
  font "Courier", :style => :bold
  text "In Courier bold"    

  font "Courier", :style => :bold_italic
  text "In Courier bold-italic"   

  font "Courier", :style => :italic
  text "In Courier italic"    

  font "Courier", :style => :normal
  text "In Normal Courier"  
  
  font "Helvetica"
  text "In Normal Helvetica"       
  
  font "Helvetica-BoldOblique"
  text "Old way still works, too"
end