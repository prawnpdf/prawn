# encoding: utf-8
#
#
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'prawn'

##
# This bug is taken from issue #102 including the comments. 
# When the bug is fixed then the third rectangle should be yellow and not green.

pdf = Prawn::Document.generate("graphics_state.pdf", :page_layout => :landscape) do
  fill_color '000000'  # Prawn thinks color space is RGB
  fill { rectangle([10, bounds.top], 10, 10) }
  save_graphics_state
  fill_color 0, 0, 0, 0  # Prawn thinks color space is CMYK  
  fill { rectangle([20, bounds.top], 10, 10) }
  restore_graphics_state  # Oops, now PDF thinks color space is RGB again
  fill_color 0, 0, 100, 0  # This won't work!
  fill { rectangle([ 30, bounds.top ], 10, 10) }
end