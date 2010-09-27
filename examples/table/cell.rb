# encoding: utf-8
#
# Low level cell and row implementation, which form the basic building
# blocks for Prawn tables.  Only necessary to know about if you plan on
# building your own table implementation from scratch or heavily modify
# the existing table system.
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

Prawn::Document.generate("cell.pdf") do 
  cell :content => "test", :padding => 10, :font_style => :bold, :size => 7
end
