# encoding: utf-8
#
# Example of two ways of indenting paragraphs
#
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate "indent_paragraphs.pdf" do |pdf|
  hello = "hello " * 50
  world = "world " * 50
  string = hello + "©\n" + world + "©"
  pdf.text(string, :indent_paragraphs => 60, :align => :justify)

  pdf.move_cursor_to(pdf.font.height)
  pdf.text(string, :indent_paragraphs => 60, :align => :justify)

  pdf.move_cursor_to(pdf.font.height * 3)
  pdf.text(string, :indent_paragraphs => 60, :align => :justify)

  # can also indent using a non-breaking space
  nbsp = Prawn::Text::NBSP
  pdf.text("\n\n\n\n#{nbsp * 10}" + hello + "\n#{nbsp * 10}" + world, :align => :justify)
end
