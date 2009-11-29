# encoding: utf-8
#
# This example demonstrates the use of the the outlines option for a new document
# it sets an initial outline item with a title
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"


Prawn::Document.generate('outlines.pdf', :outlines => "First Page") do
  text "This is the first Page"
end
