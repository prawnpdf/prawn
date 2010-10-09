# encoding: utf-8
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))
 
Prawn::Document.generate("subtable.pdf") do |pdf|
  
  subtable = Prawn::Table.new([%w[one two], %w[three four]], pdf)

  pdf.table([["Subtable ->", subtable, "<-"]])

end

