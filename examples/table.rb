$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("table.pdf") do 
  table [["foo","baaar"],["This is","a sample"],["Table","dontchaknow?"]]
end
