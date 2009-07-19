# encoding: utf-8
#
# This demonstrates basic page layout and landscape options for Prawn
# documents.  The style used here is a bit out of date, see 
# multi_page_layout.rb for a more modern example.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

def pdf(*options)  
  Prawn::Document.new(*options)
end
                                     
# defaults to portrait and US letter
portrait_letter = pdf 
portrait_letter.render_file "portrait_letter.pdf"

landscape_letter = pdf(:page_layout => :landscape)
landscape_letter.render_file "landscape_letter.pdf"  

portrait_legal = pdf(:page_size => "LEGAL")
portrait_legal.render_file "portrait_legal.pdf" 

landscape_legal = pdf(:page_size => "LEGAL", :page_layout => :landscape)
landscape_legal.render_file "landscape_legal.pdf"

portrait_a4 = pdf(:page_size => "A4")
portrait_a4.render_file "portrait_a4.pdf"

landscape_a4 = pdf(:page_size => "A4", :page_layout => :landscape)
landscape_a4.render_file("landscape_a4.pdf")

