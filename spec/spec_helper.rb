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

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/extensions/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/extensions/**/*.rb"].each {|f| require f }

RSpec.configure do |config|
  config.mock_framework = :mocha
  config.include EncodingHelpers
end

def create_pdf(klass=Prawn::Document)
  @pdf = klass.new(:margin => 0)
end    

# Make some methods public to assist in testing
module Prawn::Graphics
  public :map_to_absolute
end

