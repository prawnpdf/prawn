# encoding: utf-8
#
# You may load another PDF while creating a new one. Just pass the loaded PDF
# filename to the <code>:template</code> option when creating/generating the new
# PDF.
#
# The provided PDF will be loaded and the its first page will be set as the
# current page. If you'd like to resume the document you may take advantage of
# two helpers: <code>page_count</code> and <code>go_to_page</code>.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = "#{Prawn::BASEDIR}/data/pdfs/multipage_template.pdf"

Prawn::Example.generate("full_template.pdf", :template => filename) do
  go_to_page(page_count)
  
  start_new_page
  
  text "Previous pages and content imported.", :align => :center
  text "This page and content is brand new.", :align => :center
end
