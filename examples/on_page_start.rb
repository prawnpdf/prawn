$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

page_start = lambda do |doc|
  doc.line [100,100], [300,300]
end

pdf = Prawn::Document.new(:on_page_start => page_start)

pdf.line [0,0], [100,100]
pdf.start_new_page
pdf.line [300,300],[400,400]
pdf.start_new_page
pdf.render_file "page_start_hooks.pdf"

