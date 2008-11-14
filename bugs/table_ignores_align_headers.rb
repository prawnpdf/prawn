# As of fadb65c303ff129d0b25a929d3b9d1f915b2f98d,
# Prawn ignores :align_headers property in tables
# when :border_style => :grid is present (Lighthouse issue #119).
#
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("table_ignores_align_headers.pdf") do
  left = "Left\njustified"
  center = "Should\nbe\ncentered"
  table [[left, left], [left, left]], :headers => [center, center], :align => :left, :align_headers => :center, :border_style => :grid
end
