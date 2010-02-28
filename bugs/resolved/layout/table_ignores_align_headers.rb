# As of fadb65c303ff129d0b25a929d3b9d1f915b2f98d,
# Prawn ignores :align_headers property in tables
# when :border_style => :grid is present (Lighthouse issue #119).
#
# NOTES: 
# 
#  * This issue can only be reproduced when :border_style => :grid is used
#
# Resolved as of 47297900dcf3f16c4765ca817f17c53fb0a5a079
# I think a bad merge created issues in edge, and this code fixes previous
# problems that are present in stable.
#
$DEBUG = true

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require "rubygems"
require "prawn"
require "prawn/layout"

Prawn::Document.generate("table_ignores_align_headers.pdf") do
  left  = "Left justified"
  left2 = "left"
  center = "centered"
  table [[left, left], [left2, left2]], :headers       => [center, center], 
                                      :align         => :left, 
                                      :align_headers => :center,
                                      :border_style  => :grid
end
