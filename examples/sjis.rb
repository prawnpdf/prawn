# coding: utf-8

# Tests passing non utf-8 data into Prawns text function. Should
# be transparently converted to utf-8 and rendered as usual.
# 
# NOTE: only works on ruby1.9 compatible VMs, and requires the current
#       font to include japanese glyphs

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

datafile = File.join(File.dirname(__FILE__), "..", "data", "shift_jis_text.txt")
sjis_str = File.open(datafile, "r:shift_jis") { |f| f.gets }

Prawn::Document.generate("sjis.pdf") do
  font "/usr/share/fonts/truetype/arphic/gkai00mp.ttf"
  text sjis_str
end
