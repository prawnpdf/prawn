require File.dirname(__FILE__) + "/../lib/prawn"

pdf = Prawn::PDF.new
pdf.render_file("test.pdf")
