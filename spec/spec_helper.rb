# encoding: utf-8

puts "Prawn specs: Running on Ruby Version: #{RUBY_VERSION}"

require "rubygems"
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib') 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'vendor','pdf-inspector','lib')
require "prawn/core"

Prawn.debug = true

ruby_19 do
 gem "test-unit", "=1.2.3"
end
require "test/spec"
require "mocha"

gem 'pdf-reader', ">=0.8"
require "pdf/reader"          
require "pdf/inspector"

def create_pdf(klass=Prawn::Document)
  @pdf = klass.new(:margin => 0)
end    
