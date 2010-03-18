# encoding: utf-8
#
# This sample demonstrates the use of the :template option when generating
# a new Document. The template PDF file is imported into a new document.

require "#{File.dirname(__FILE__)}/../example_helper.rb"

filename = "#{Prawn::BASEDIR}/reference_pdfs/curves.pdf"

Prawn::Document.generate("template.pdf", :template => filename) do
  text "Curves!", :size => 18, :align => :center
end
