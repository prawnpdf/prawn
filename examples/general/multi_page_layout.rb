# encoding: utf-8
#
# This demonstrates that Prawn can modify page size, margins and layout for 
# each individual page, via Document#start_new_page()
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "prawn"

Prawn::Document.generate("multi-layout.pdf", :page_layout => :landscape) do |pdf|
   pdf.text "This is on a landscaped page" 
   pdf.start_new_page(:layout => :portrait)
   pdf.text "This is on a portrait page"   
   pdf.start_new_page(:size => "LEGAL")
   pdf.text "This is on legal paper size"      
   pdf.start_new_page(:left_margin => 150, :right_margin => 150)
   pdf.text "This page has very wide left and right margins, causing a squeeze"
end