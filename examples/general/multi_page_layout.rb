# encoding: utf-8
#
# This demonstrates that Prawn can modify page size, margins and layout for 
# each individual page, via Document#start_new_page()
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("multi-layout.pdf", :page_layout => :landscape) do |pdf|
   pdf.text "This is on a landscaped page" 
   pdf.start_new_page(:layout => :portrait)
   pdf.text "This is on a portrait page"   
   pdf.start_new_page(:size => "LEGAL")
   pdf.text "This is on legal paper size"      
   pdf.start_new_page(:left_margin => 150, :right_margin => 150)
   pdf.text "This page has very wide left and right margins, causing a squeeze"
   pdf.start_new_page(:margin => 300, :right_margin => 0)
   pdf.text "This page has even wider margins on all sides except for the right side, where it's 0"
end
