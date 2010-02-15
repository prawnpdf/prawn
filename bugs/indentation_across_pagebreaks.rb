# As of 2009.02.13, indentation does not work across page breaks. [#86]

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn/core"

Prawn::Document.generate("indent_page_breaks.pdf") do
  text "heading", :size => 14, :style => :bold

  indent(20) do
    100.times do
      text "test"
    end
  end
end
   
