# encoding: utf-8
#
#
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'prawn'

##
# This bug is simplification of issue #183. 
# When the bug is fixed then a rectangle should show on both pages in Acrobat Reader.

pdf = Prawn::Document.generate("color_space_issues.pdf", :page_layout => :landscape) do
  stroke_color "000000"
  stroke { rectangle([10, bounds.top], 10, 10) }
  start_new_page
  stroke_color "000000"
  stroke { rectangle([10, bounds.top], 10, 10) }
end
  