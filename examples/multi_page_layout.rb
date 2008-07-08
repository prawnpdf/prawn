# coding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("multi-layout.pdf", :page_layout => :landscape) do |pdf|
   pdf.text "This is on a landscaped page" 
   pdf.page_layout = :portrait
   pdf.start_new_page
   pdf.text "This is on a portrait page"   
   pdf.page_size = "LEGAL"    
   pdf.start_new_page
   pdf.text "This is on legal paper size"    
   pdf.margins[:left]  = 150
   pdf.margins[:right] = 150     
   pdf.start_new_page
   pdf.text "This page has very wide left and right margins, causing a squeeze"
end