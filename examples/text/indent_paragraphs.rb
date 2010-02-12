# encoding: utf-8
#
# An early example of basic text generation at absolute positions.
# Mostly kept for nostalgia.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "indent_paragraphs.pdf" do |pdf|
  hello = "hello " * 50
  world = "world " * 50
  pdf.text(hello + "\n" + world, :indent_paragraphs => 60)

  pdf.move_cursor_to(pdf.font.height)
  pdf.text(hello + "\n" + world, :indent_paragraphs => 60)

  pdf.move_cursor_to(pdf.font.height * 3)
  pdf.text(hello + "\n" + world, :indent_paragraphs => 60)
end
