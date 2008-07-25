require "prawn"
require "pdf/writer"

pdf = PDF::Writer.new
pdf.add_image_from_file "#{Prawn::BASEDIR}/data/images/ruport.png", 100, 500 
pdf.save_as("image-pdfw.pdf")
