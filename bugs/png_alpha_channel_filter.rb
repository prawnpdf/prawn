$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'prawn'

image_file = File.expand_path('../../data/images/prawn.png', __FILE__)

pdf = Prawn::Document.new
pdf.image image_file
pdf.render_file("works.pdf")

require 'mathn'  # Re-defines '/' operation !
pdf = Prawn::Document.new
pdf.image image_file
pdf.render_file("broken.pdf")
