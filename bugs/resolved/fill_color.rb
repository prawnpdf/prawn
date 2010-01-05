# encoding: utf-8
#
# As of 9e48a6 (2009.01.03), this code fails to recognize fill_color in tables.
# Resolved in 664760 (2009.01.05)
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..','lib')
require "prawn/core"
require "prawn/layout"

Prawn::Document.generate("fill_color.pdf") do
  fill_color "ff0000"
  table [%w[1 2 3],%w[4 5 6],%w[7 8 9]], 
end

