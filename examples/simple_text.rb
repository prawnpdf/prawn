$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate "hello.pdf" do       
  fill_color "0000ff"
  text "Hello World", :at => [200,720], :size => 32       
  font "Times-Roman"     
  fill_color "ff0000"
  text "Overcoming singular font limitation", :at => [5,5]    
  start_new_page        
  font "Courier"       
  text "Goodbye World", :at => [288,50]     
end