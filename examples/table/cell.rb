# encoding: utf-8
#
# Low level cell and row implementation, which form the basic building
# blocks for Prawn tables.  Only necessary to know about if you plan on
# building your own table implementation from scratch or heavily modify
# the existing table system.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate("cell.pdf") do 
  cell :content => "test", :padding => 10, :style => :bold, :size => 7
end
