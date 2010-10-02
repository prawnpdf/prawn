# encoding: utf-8
#
# This sample demonstrates the use of the :template option when generating
# a new Document. The template PDF file is imported into a new document.

require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = "#{Prawn::BASEDIR}/reference_pdfs/curves.pdf"

Prawn::Document.generate("template.pdf", :template => filename) do
  text "Previous pages and content imported", :size => 18, :align => :center
  text "This page and content is brand new", :size => 18, :align => :center
end
