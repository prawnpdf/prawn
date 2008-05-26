$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

pdf = Prawn::Document.new

box = Prawn::TextBox.new("The rains in Spain fall mainly on the plains", :width => 100)
box.render_on_pdf(pdf, [200, 200])

box.width = 150
box.border = 2
box.render_on_pdf(pdf, [200, 400])

box.width = 150
box.padding = 10
box.render_on_pdf(pdf, [200, 600])

pdf.render_file "boxes.pdf"
