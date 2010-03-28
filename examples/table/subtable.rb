# encoding: utf-8
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"
 
Prawn::Document.generate("subtable.pdf") do |pdf|
  
  subtable = Prawn::Table.new([%w[one two], %w[three four]], pdf)

  pdf.table([["Subtable ->", subtable, "<-"]])

end

