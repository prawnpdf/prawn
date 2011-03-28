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
  number_pages "<page> in a total of <total>", :at => [bounds.right - 100, 20],
                                               :width => 150,
                                               :page_filter => :all
end

Prawn::Document.generate("page_with_numbering_extra_options.pdf") do
  text "Hai"
  start_new_page :layout => :landscape
  text "bai"
  start_new_page :layout => :portrait
  text "-- Hai again"
  number_pages "<page> in a total of <total>", :at => [bounds.right - 150, 20],
                                               :width => 150,
                                               :align => :right,
                                               :page_filter => :odd,
                                               :start_count_at => 12,
                                               :total_pages => 15
                                               
  number_pages "<page> in a total of <total>", :at => [bounds.left + 50, 20],
                                               :width => 150,
                                               :align => :left,
                                               :page_filter => :even,
                                               :start_count_at => 13,
                                               :total_pages => 15,
                                               :color => "FF0000"
end
