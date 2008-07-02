# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

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

