# As of fadb65c303ff129d0b25a929d3b9d1f915b2f98d,
# Prawn ignores :align_headers property in tables
# when :border_style => :grid is present (Lighthouse issue #119).
#
# NOTES: 
# 
#  * This issue can only be reproduced when :border_style => :grid is used
#
$DEBUG = true

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("table_ignores_align_headers.pdf") do
  left  = "Left justified"
  left2 = "left"
  center = "centered"
  table [[left, left], [left2, left2]], :headers       => [center, center], 
                                      :align         => :left, 
                                      :align_headers => :center,
                                      :border_style  => :grid
end
