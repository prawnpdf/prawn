# encoding: utf-8
# 
# Rounded rectangle example demonstrating both stroke and stroke and fill. 
# A rectangle with rounded join_style is added just for comparison.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

pdf = Prawn::Document.new
pdf.font_size 8
pdf.draw_text "a stroked rounded rectangle:", :at => [30, 575]
pdf.stroke_rounded_rectangle([50, 550], 50, 100, 10)
pdf.draw_text "a stroked and filled rounded rectangle:", :at => [180, 575]
pdf.fill_and_stroke_rounded_rectangle([200, 550], 50, 100, 10)
pdf.draw_text "a regular rectangle with rounded join style;", :at => [330, 575]
pdf.draw_text "needs thick line width for similar result:", :at => [330, 565]
pdf.join_style :round
pdf.line_width 10
pdf.stroke_rectangle([350, 550], 50, 100)

pdf.render_file "rounded_rectangle.pdf"
