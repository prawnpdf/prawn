# encoding: utf-8
#
# This example demonstrates the use of the the outlines option for a new document
# it sets an initial outline item with a title
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"


Prawn::Document.generate('outlines.pdf') do
  text "This is the first Chapter"
  start_new_page
  text "This is the second Chapter"
  generate_outline( 
    {
      ['Chapter 1', 0] => [
        ['Page 1', 0]
      ]
    }, 
    {
      ['Chapter 2', 1] => [
        ['Page 2', 1]
      ]
    })
end
