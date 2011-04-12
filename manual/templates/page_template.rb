# encoding: utf-8
#
# If you only need to load some pages from another PDF, you can accomplish it
# with the <code>start_new_page</code> method. You may pass it a
# <code>:template</code> option with the path for an existing pdf and a
# <code>:template_page</code> option to specify which page to load.
#
# The following example loads some pages from an existing PDF. If we don't
# specify the <code>:template_page</code> option, the first page of the template
# PDF will be loaded. That's what happens on the first load below. Then we load
# a page by specifying the <code>:template_page</code> option and then we do it
# again this time adding some content to the loaded page.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "Please scan the next 3 pages to see the page templates in action."
  move_down 10
  text "You also might want to look at the pdf used as a template: "
  url = "https://github.com/sandal/prawn/raw/master/data/pdfs/form.pdf"
  formatted_text [{:text => url, :link => url}]
  
  filename = "#{Prawn::BASEDIR}/data/pdfs/form.pdf"
  start_new_page(:template => filename)
  
  start_new_page(:template => filename, :template_page => 2)
  
  start_new_page(:template => filename, :template_page => 2)
  
  fill_color "FF8888"
  
  text_box "John Doe", :at => [75, cursor-75]
  text_box "john@doe.com", :at => [75, cursor-105]
  text_box "John Doe inc", :at => [75, cursor-135]
  text_box "You didn't think I'd tell, did you?", :at => [75, cursor-165]
  
  fill_color "000000"
end
