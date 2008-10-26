# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate "font_size.pdf", :page_size => "A4" do
  font 'Helvetica'
  font.size = 16
  
  text 'Font at 16 point'
  
  font.size 9 do
    text 'Font at 9 point'
    text 'Font at manual override 20 point', :size => 20
    text 'Font at 9 point'
  end
  
  font("Times-Roman", :style => :italic, :size => 12) do
    text "Font in times at 12"
    font.size(16) { text "Font in Times at 16" }
  end
  
  text 'Font at 16 point'
  
  font "Courier", :size => 40
  text "40 pt!"
end