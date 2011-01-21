# encoding: utf-8
#
# Prawn manual foreword page. 
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  text "Foreword, by Greg Brown", :size => 20
end
