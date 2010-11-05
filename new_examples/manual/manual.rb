# encoding: utf-8
#
# Generates example document for the Graphics package
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Example.generate("manual.pdf") do
  text "Prawn by Example", :size => 40
  
  outline.define do
    section "Prawn by Example", :destination => 1
  end
  
  start_new_page
  
  load_package "graphics"
end
