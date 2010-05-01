# encoding: utf-8
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
 
Prawn::Document.generate("inline_format_table.pdf") do 

  table([%w[foo bar baz<b>baz</b>], %w[baz bar <i>foo</i>foo]], 
        :cell_style => { :padding => 12, :inline_format => true },
        :width => bounds.width)

end

