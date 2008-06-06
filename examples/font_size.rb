$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate "font_size.pdf", :page_size => "A4" do
  font 'Helvetica'
  font_size! 16
  
  text 'Large text!'
  
  font_size 9 do
    text 'Small text'
    text 'But this?', :size => 20
  end
  
  text 'Large again!'
end
