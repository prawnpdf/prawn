# As of 236001715a398198a5f8cae19c0f093b391cf6ac,
# table was not properly handling :spacing calculations
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require "rubygems"
require "prawn"
require "prawn/layout"

Prawn::Document.generate("table_spacing_calculations.pdf") do
  text_options.update(:spacing => 10)

  table [["Foo\n"*10,"Bar"]*5]
end
