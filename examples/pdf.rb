require File.dirname(__FILE__) + "/../lib/prawn"

pdf = Prawn::PDF.new
#pdf.start_new_page
pdf.line(100,741,100,641)
pdf.render_file("test.pdf")
