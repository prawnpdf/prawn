# encoding: utf-8
#
# Demonstrates simple curve and circle usage
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

pdf = Prawn::Document.new
pdf.move_to [100,100]
pdf.stroke_curve_to [50,50], :bounds => [[60,90], [60, 90]]  
pdf.fill_circle_at [200,200], :radius => 10
pdf.render_file "curves.pdf"