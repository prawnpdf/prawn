# encoding: utf-8
#
# As of Prawn 0.3, it is possible to generate a Euro using the built-in
# AFM files.  However, you need to be sure to manually add spacing around it,
# as its calculated width in the AFM files seem to be wrong.
#
# We are investigating this issue, but it does not seem to be Prawn specific.
# If you need precision spacing, use a TTF file instead and the issue will
# go away.
#
require "#{File.dirname(__FILE__)}/../example_helper.rb"

Prawn::Document.generate "euro.pdf" do
  text "A Euro! € ©", :size => 32
end