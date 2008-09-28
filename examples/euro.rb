# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate "euro.pdf" do
  text "A Euro! € ©", :size => 32
end
