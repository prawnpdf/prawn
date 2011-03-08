# encoding: utf-8
#
#
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'prawn'

##
# This bug was reported in comments in issue #200 
# When the bug is fixed the stamp text and shape color should be set to a blue CMYK color

pdf = Prawn::Document.generate("stamp_color_issues.pdf", :margin => [40, 45, 50, 45]) do
  text "Page text starts out with RGB black color"
  create_stamp("logo") do
    fill_color(100, 100, 20, 0)
    stroke_color(100, 100, 20, 0)
    move_down 50
    text "But in a stamp I can create CMYK colored text and shapes"
    fill_and_stroke_rounded_rectangle([200, 550], 50, 100, 10)
  end
  stamp('logo')
  draw_text "And non stamped text is not affected", :at => [10, 400]
end
