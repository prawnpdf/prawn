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
  pdf.number_pages [:text => "Page <page> of <total>",
                    :size => 14,
                    :color => "333333",
                    :styles => [:bold]],
                    {:width => 100,
                     :height => 50,
                     :overflow => :truncate,
                     :at => [bounds.right - 50, bounds.bottom-50],
                     :page_filter => lambda{ |pg| pg != 1 },
                     :start_at => 5}
end
