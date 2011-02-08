# encoding: utf-8
#
# Demonstrates simple curve and circle usage
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

pdf = Prawn::Document.new
pdf.move_to [100,100]
pdf.stroke_curve_to [50,50], :bounds => [[60,90], [60, 90]]  
pdf.fill_circle [200,200], 10
pdf.render_file "curves.pdf"
