# cell attributes aren't taken into account while
# auto-calculating widths

require 'rubygems'
require 'prawn'
require 'prawn/layout'

pdf = Prawn::Document.new
pdf.font 'Helvetica'
cell1 = { :text => 'nnnnnnnnnnnnnnnnnnnnnn', :font_style => :normal }
cell2 = { :text => 'nnnnnnnnnnnnnnnnnnnnnn', :font_style => :bold_italic }
pdf.table [[cell1]]
pdf.table [[cell2]]

cell3 = { :text => 'nnnnnnnnnnnnnnnnnnnnnn', :font_size => 8 }
cell4 = { :text => 'nnnnnnnnnnnnnnnnnnnnnn', :font_size => 24 }
pdf.table [[cell3]]
pdf.table [[cell4]]

pdf.render_file("widths.pdf")
