# As of bbe1df6530455dff41768bcc329bdc7cfdfaded1 (and earlier),
# Prawn does not properly display cells with newlines in tables.
#
# Fixed in e28cf53b5d05e6cb343e8dd5265c57d5f24ef4da [#76]
#
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib')
require "rubygems"
require "prawn"
require "prawn/layout"

Prawn::Document.generate("table_supresses_newlines.pdf") do
  table [["test\n\naaaa","test\n\nbbbb"],
        ["test\n\ncccc", "test\n\ndddd"]],  :border_style => :grid
    
  cell [100,100], :text => "test\n\naaaa"
end
