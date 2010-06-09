# encoding: utf-8
#
# Example of character spacing
#
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "character_spacing.pdf" do |pdf|
  string = "hello world " * 50
  pdf.text(string, :character_spacing => 2.5)
  pdf.text(string)
end
