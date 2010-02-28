# encoding: utf-8
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
 
Prawn::Document.generate("widths.pdf") do 

  text "Some 300-pt tables:"

  table([%w[A B C]], :width => 300)
  move_down 12

  table([%w[A B C], %w[D Everything\ under\ the\ sun F]], :width => 300)
  move_down 12

  # TODO: what should this be doing? Like the current prawn-layout, it does
  # not attempt to reflow the second column.
  # table([["A", "Blah " * 20, "C"]], :width => 300)
  # move_down 12

end
