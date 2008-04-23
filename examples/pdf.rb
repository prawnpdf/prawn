$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib') 
require "prawn"

pdf = Prawn::Document.new
#pdf.start_new_page
pdf.line(100,741,100,641)
pdf.render_file("test.pdf")
