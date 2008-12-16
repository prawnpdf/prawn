# encoding: utf-8
#
# Demonstrates simple curve and circle usage
#
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require "prawn"

pdf = Prawn::Document.new
pdf.move_to [100,100]
pdf.stroke_curve_to [50,50], :bounds => [[20,90], [90,90]]  
pdf.fill_circle_at [200,200], :radius => 10
pdf.render_file "curves.pdf"