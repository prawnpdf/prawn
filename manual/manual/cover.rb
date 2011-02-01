# encoding: utf-8
#
# Prawn manual how to read this manual page. 
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "Prawn by Example", :size => 40
end
