$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate "kerning.pdf" do
  text "To kern?", :at => [200,720], :size => 24, :kerning => true
  text "To not kern?", :at => [200,620], :size => 24, :kerning => false  
end