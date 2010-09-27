# encoding: utf-8
#
# This example demonstrates how to add a "page k of n"
# template to your documents.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate("page_with_numbering.pdf") do
  text "Hai"
  start_new_page
  text "bai"
  start_new_page
  text "-- Hai again"
  number_pages "<page> in a total of <total>", [bounds.right - 50, 0]  
end
