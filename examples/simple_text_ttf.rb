$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate "hello.pdf" do       
  fill_color "0000ff"
  font "comicsans.ttf", :ttf
  text "Hello World", :at => [200,720], :size => 32       
end
