# encoding: utf-8
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("multi_page_table.pdf") do

  table([%w[Some data in a table]] * 50)

end
