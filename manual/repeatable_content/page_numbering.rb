# encoding: utf-8
#
# The <code>number_pages</code> method is a simple way to number the pages of
# your document. It should be called towards the end of the document since
# pages created after the call won't be numbered.
#
# It accepts a string with two optional tags: <code><page></code> will be
# replaced by the page number and <code>total</code> by the total number of
# pages at the moment of the call. The string will be rendered starting at
# the array coordinates provided by the second argument.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "This is the first page!"
  
  10.times do
    start_new_page
    text "Here comes yet another page."
  end
  
  number_pages("<page> in a total of <total>", [bounds.right - 100, 0])
  
  start_new_page
  text "See. This page isn't numbered and doesn't count towards the total."
end
