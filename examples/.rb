$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'prawn'

Prawn::Document.generate('.pdf') do

end