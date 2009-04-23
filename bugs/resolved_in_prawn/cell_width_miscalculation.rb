# encoding: utf-8
#
# As of 40c7bde9690e5174b6a958a5df6b2aabc6b8b041 this code produces an extra
# empty line of text in row 2.
#
# Simple rounding of string_width floats seems to fix this issue, see the patch
# in 09c837466c31bb715f1276118c606e20477577df.
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require "rubygems"
require "prawn"
require "prawn/layout"

Prawn::Document.generate("broken_table.pdf") do 
  font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf"
  table [["foo",    "baaar",             "1" ],
         ["This is","a sample",          "2" ],
         ["Table",  "dont\ncha\nknow?",  "3" ]],
    :font_size => 30, 
    :padding   => 10, 
    :border    => 2, 
    :position  => :center
end
 
