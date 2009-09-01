# encoding: utf-8

puts "Prawn/Security specs: Running on Ruby Version: #{RUBY_VERSION}"

require "rubygems"
require "test/spec"                                                
require "mocha"
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib') 
require "prawn/core"
require "prawn/security"

Prawn.debug = true

