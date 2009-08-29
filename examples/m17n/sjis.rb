# encoding: utf-8
#
# FIXME: Introducing TTFunk into Prawn broke this example and a cooresponding
# test.  Ticket: #139
#
# Tests passing non utf-8 data into Prawns text function. Should
# be transparently converted to utf-8 and rendered as usual.
# 
# NOTE: only works on ruby1.9 compatible VMs, and requires the current
#       font to include japanese glyphs. On 1.8.x comaptible VMs, an exception
#       will be raised.

require "#{File.dirname(__FILE__)}/../example_helper.rb"

begin
  ruby_19 do  
    datafile = File.join(File.dirname(__FILE__), "..", "..", "data", 
      "shift_jis_text.txt")
    sjis_str = File.open(datafile, "r:shift_jis") { |f| f.gets }

    Prawn::Document.generate("sjis.pdf") do
      font "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf"
      text sjis_str
    end       
  end
rescue
  puts "\n FIXME: SJIS Broken due to TTFunk integration."
end
