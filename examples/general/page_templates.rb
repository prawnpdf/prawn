# encoding: utf-8
#
# This sample demonstrates the use of the :template option when using #start_new_page to add a
# new page. Only one page of the template is currently imported for the template and which page of 
# the pdf template is used can be specified with the :template_page option which defaults to 1.

require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = "#{Prawn::BASEDIR}/data/pdfs/multipage_template.pdf"

Prawn::Document.generate("page_template.pdf") do
  text "This is the first page and content is brand new", :size => 18, :align => :center
  start_new_page(:template => filename, :template_page => 2)
  move_down 20
  text "Here is some content that has been added to the page template", :size => 18, :align => :center
  start_new_page(:template => filename, :template_page => 3)
  move_down 20
  text "Here is content that has been added to page 3 of the template", :size => 18, :align => :center
end
