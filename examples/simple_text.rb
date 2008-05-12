$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

pdf = Prawn::Document.new 
pdf.text "Hello World", :at => [200,720], :size => 32       
pdf.font "Times-Roman"
pdf.text "Overcoming singular font limitation", :at => [5,5]
pdf.start_new_page   
pdf.font "Courier"       
pdf.text "Goodbye World", :at => [288,50]
pdf.render_file "hello.pdf"           