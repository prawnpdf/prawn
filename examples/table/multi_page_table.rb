# encoding: utf-8
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate("multi_page_table.pdf") do

  table([%w[Some data in a table]] * 50)

end
