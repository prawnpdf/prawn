$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate "hello-ttf.pdf" do       
  fill_color "0000ff"
  font "#{Prawn::BASEDIR}/data/fonts/comicsans.ttf" 
  text "Hello World", :at => [200,720], :size => 32          
  font "#{Prawn::BASEDIR}/data/fonts/Chalkboard.ttf"          
  text "Blah Blah Blah " * 100           
end
