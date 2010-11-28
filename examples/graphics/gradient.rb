# encoding: utf-8
#
# Demonstrate use of gradients
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

pdf = Prawn::Document.new(:margin => 0)

pdf.stroke_gradient [0, pdf.bounds.height], pdf.bounds.width, pdf.bounds.height/2, '69CD31', '0000FF'
pdf.fill_gradient [0, pdf.bounds.height], pdf.bounds.width, pdf.bounds.height/2, 'FF0000', '00FF00'

pdf.rectangle [10, pdf.bounds.height-10], 100, pdf.bounds.height-20
pdf.line_width 20
pdf.fill_and_stroke

pdf.fill_gradient [150, 250], 400, 70, 'F0FF00', '0000FF'
pdf.bounding_box [150, 250], :width => 450, :height => 150 do
  pdf.text "Gradient!", :size => 80
end

pdf.render_file 'gradient.pdf'

