# encoding: utf-8

puts "Prawn specs: Running on Ruby Version: #{RUBY_VERSION}"

require "rubygems"
require "bundler"
Bundler.setup

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib') 
require "prawn"

Prawn.debug = true

#require "test/spec"
require "rspec"
require "mocha/api"
require "pdf/reader"
require "pdf/inspector"

RSpec.configure do |config|
  config.mock_framework = :mocha
end

def create_pdf(klass=Prawn::Document)
  @pdf = klass.new(:margin => 0)
end    

# Make some methods public to assist in testing
module Prawn::Graphics
  public :map_to_absolute
end

require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[extensions mocha]))

