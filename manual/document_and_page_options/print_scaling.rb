# encoding: utf-8
#
# When printing a PDF, many PDF readers automatically scales the content to fit within the page margins. This is not
# always the wanted behaviour and some PDF readers does not even offer a possibility to disable this feature.
#
# Prawn can disable this feature directly in the PDF document, to disable automatic print scaling just supply
# <code>:print_scaling => :none</code> when creating a document.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate("print_scaling.pdf",
                         :page_layout => :landscape
) do
  text "When you print this document, the scale to fit in print preview should be disabled by default."
end
