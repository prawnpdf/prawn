# encoding: utf-8
#
# Prawn manual foreword page. 
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  header("Foreword, by Gregory Brown")
  text "This will be written just before 1.0, to give the"+
       " core team something to look forward to."
  end
