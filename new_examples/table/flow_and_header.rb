# encoding: utf-8
#
# If the table cannot fit on the current page it will flow to the next just
# like the free flowing text. If you'd like to have the header repeated on
# subsequent pages set the <code>:header</code> option to true.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  data = [["This row should be repeated on every new page"]]
  data += [["..."]] * 30
  
  table(data, :header => true)
end
