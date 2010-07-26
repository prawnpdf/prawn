# encoding: utf-8
#
#
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'prawn'

pdf = Prawn::Document.new(:page_layout => :landscape) do
  text "here is the first rendering"
end

pdf.render_file("multiple_rendering.pdf")

pdf.move_down 10
pdf.text "here is another rendering"

pdf.render_file("multiple_rendering_2.pdf")



