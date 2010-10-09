# encoding: utf-8
#
# Example of character spacing
#
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate "character_spacing.pdf" do |pdf|
  string = "hello world " * 50
  pdf.text(string, :character_spacing => 2.5)
  pdf.text(string)
end
